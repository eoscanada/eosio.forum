#include "forum.hpp"

#define VALIDATE_JSON(Variable, MAX_SIZE)\
::forum::validate_json(\
    Variable,\
    MAX_SIZE,\
    #Variable " must be a JSON object (if specified).",\
    #Variable " should be shorter than " #MAX_SIZE " bytes."\
)

EOSIO_ABI(forum, (post)(unpost)(propose)(unpropose)(vote)(unvote)(cleanvotes)(status))

// @abi
void forum::post(
    const account_name poster,
    const std::string& post_uuid,
    const std::string& content,
    const account_name reply_to_poster,
    const std::string& reply_to_post_uuid,
    const bool certify,
    const std::string& json_metadata
) {
    require_auth(poster);

    eosio_assert(content.size() > 0, "content should be longer than 0 character.");
    eosio_assert(content.size() < 1024 * 10, "content should be less than 10 KB.");

    eosio_assert(post_uuid.size() > 0, "post_uuid should be longer than 0 character.");
    eosio_assert(post_uuid.size() < 128, "post_uuid should be shorter than 128 characters.");

    if (reply_to_poster == 0) {
        eosio_assert(reply_to_post_uuid.size() == 0, "If reply_to_poster is not set, reply_to_post_uuid should not be set.");
    } else {
        eosio_assert(is_account(reply_to_poster), "reply_to_poster must be a valid account.");
        eosio_assert(reply_to_post_uuid.size() > 0, "reply_to_post_uuid should be longer than 0 character.");
        eosio_assert(reply_to_post_uuid.size() < 128, "reply_to_post_uuid should be shorter than 128 characters.");
    }

    VALIDATE_JSON(json_metadata, 8192);
}

// @abi
void forum::unpost(const account_name poster, const std::string& post_uuid) {
    require_auth(poster);

    eosio_assert(post_uuid.size() > 0, "post_uuid should be longer than 0 character.");
    eosio_assert(post_uuid.size() < 128, "post_uuid should be shorter than 128 characters.");
}

// @abi
void forum::propose(
    const account_name proposer,
    const name proposal_name,
    const std::string& title,
    const std::string& proposal_json
) {
    require_auth(proposer);

    eosio_assert(title.size() < 1024, "title should be less than 1024 characters long.");

    VALIDATE_JSON(proposal_json, 32768);

    proposals proposal_table(_self, proposer);
    eosio_assert(proposal_table.find(proposal_name) == proposal_table.end(), "proposal with the same name exists");

    proposal_table.emplace(proposer, [&](auto& row) {
        row.proposal_name = proposal_name;
        row.title = title;
        row.proposal_json = proposal_json;
    });
}

// @abi
void forum::unpropose(const account_name proposer, const name proposal_name) {
    require_auth(proposer);

    proposals proposal_table(_self, proposer);

    auto& row = proposal_table.get(proposal_name, "proposal not found");
    proposal_table.erase(row);
}

// @abi
void forum::status(const account_name account, const std::string& content) {
    require_auth(account);

    eosio_assert(content.size() < 256, "content should be less than 256 characters.");

    statuses status_table(_self, _self);

    if (content.size() == 0) {
        auto& row = status_table.get(account, "no previous status entry for this account.");
        status_table.erase(row);
    } else {
        update_status(status_table, account, [&](auto& row) {
            row.content = content;
        });
    }
}

// @abi
void forum::vote(
    const account_name voter,
    const account_name proposer,
    const name proposal_name,
    const std::string& proposal_hash,
    uint8_t vote,
    const std::string& vote_json
) {
    require_auth(voter);

    proposals proposal_table(_self, proposer);
    proposal_table.get(proposal_name, "proposal_name does not exist under proposer's scope");

    // The proposal_hash should be a hash of "title" + the JSON in the `proposal_json` field, appended directly.
    // TODO: check that here.
    eosio_assert(proposal_hash.size() < 128, "proposal_hash should be less than 128 characters long.");

    VALIDATE_JSON(vote_json, 8192);

    votes vote_table(_self, proposer);
    update_vote(vote_table, proposal_name, voter, [&](auto& row) {
        row.vote = vote;
        row.vote_json = vote_json;
    });
}

// @abi
void forum::unvote(
    const account_name voter,
    const account_name proposer,
    const name proposal_name,
    const std::string& proposal_hash
) {
    require_auth(voter);

    proposals proposal_table(_self, proposer);
    proposal_table.get(proposal_name, "proposal_name does not exist under proposer's scope");

    // The proposal_hash should be a hash of "title" + the JSON in the `proposal_json` field, appended directly.
    // TODO: check that here.
    eosio_assert(proposal_hash.size() < 128, "proposal_hash should be less than 128 characters long.");

    votes vote_table(_self, proposer);

    auto index = vote_table.template get_index<N(votekey)>();
    auto vote_key = compute_vote_key(proposal_name, voter);

    auto itr = index.find(vote_key);
    eosio_assert(itr != index.end(), "no vote exists for this proposal_name/voter pair");

    vote_table.erase(*itr);
}

void forum::cleanvotes(
    const account_name proposer,
    const name proposal_name,
    uint64_t max_count
) {
    proposals proposal_table(_self, proposer);

    auto itr = proposal_table.find(proposal_name);
    eosio_assert(itr == proposal_table.end(), "proposal_name must not exist anymore");

    votes vote_table(_self, proposer);
    auto index = vote_table.template get_index<N(votekey)>();

    auto vote_key_lower_bound = compute_vote_key(proposal_name, 0x0000000000000000);
    auto vote_key_upper_bound = compute_vote_key(proposal_name, 0xFFFFFFFFFFFFFFFF);

    auto lower_itr = index.lower_bound(vote_key_lower_bound);
    auto upper_itr = index.upper_bound(vote_key_upper_bound);

    uint64_t count = 0;
    while (count < max_count && lower_itr != upper_itr) {
        lower_itr = index.erase(lower_itr);
        count++;
    }
}

/// Helpers

void forum::update_status(
    statuses& status_table,
    const account_name account,
    const function<void(statusrow&)> updater
) {
    auto itr = status_table.find(account);
    if (itr == status_table.end()) {
        status_table.emplace(account, [&](auto& row) {
            row.account = account;
            row.updated_at = now();
            updater(row);
        });
    } else {
        status_table.modify(itr, account, [&](auto& row) {
            row.updated_at = now();
            updater(row);
        });
    }
}

void forum::update_vote(
    votes& vote_table,
    const name proposal_name,
    const account_name voter,
    const function<void(voterow&)> updater
) {
    auto index = vote_table.template get_index<N(votekey)>();
    auto vote_key = compute_vote_key(proposal_name, voter);

    auto itr = index.find(vote_key);
    if (itr == index.end()) {
        vote_table.emplace(voter, [&](auto& row) {
            row.id = vote_table.available_primary_key();
            row.proposal_name = proposal_name;
            row.voter = voter;
            row.updated_at = now();
            updater(row);
        });
    } else {
        index.modify(itr, voter, [&](auto& row) {
            row.updated_at = now();
            updater(row);
        });
    }
}

// Do not use directly, use the VALIDATE_JSON macro instead!
void forum::validate_json(
    const string& payload,
    size_t max_size,
    const char* not_object_message,
    const char* over_size_message
) {
    if (payload.size() <= 0) return;

    eosio_assert(payload[0] == '{', not_object_message);
    eosio_assert(payload.size() < max_size, over_size_message);
}

