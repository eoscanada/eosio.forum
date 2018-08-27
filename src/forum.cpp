#include "forum.hpp"

#define VALIDATE_JSON(Variable, MAX_SIZE)\
::forum::validate_json(\
    Variable,\
    MAX_SIZE,\
    #Variable " must be a JSON object (if specified).",\
    #Variable " should be shorter than " #MAX_SIZE " bytes."\
)

EOSIO_ABI(forum, (propose)(expire)(vote)(unvote)(clnproposal)(post)(unpost)(status))

// @abi
void forum::propose(
    const account_name proposer,
    const name proposal_name,
    const string& title,
    const string& proposal_json,
    const time_point_sec& expires_at
) {
    require_auth(proposer);

    eosio_assert(title.size() < 1024, "title should be less than 1024 characters long.");
    VALIDATE_JSON(proposal_json, 32768);

    // Not a perfect assertion since we are not doing real date computation, but good enough for our use case
    time_point_sec max_expires_at = time_point_sec(now() + SIX_MONTHS_IN_SECONDS);
    eosio_assert(expires_at <= max_expires_at, "expires_at must be within 6 months from now.");

    proposals proposal_table(_self, proposer);
    eosio_assert(proposal_table.find(proposal_name) == proposal_table.end(), "proposal with the same name exists.");

    eosio_assert(!has_votes_on_proposal_already(proposer, proposal_name),
                 "proposal with same name has still uncleaned votes, clean votes before re-using proposal name.");

    proposal_table.emplace(proposer, [&](auto& row) {
        row.proposal_name = proposal_name;
        row.title = title;
        row.proposal_json = proposal_json;
        row.created_at = time_point_sec(now());
        row.expires_at = expires_at;
    });
}

// @abi
void forum::expire(const account_name proposer, const name proposal_name) {
    require_auth(proposer);

    proposals proposal_table(_self, proposer);
    auto itr = proposal_table.find(proposal_name);

    eosio_assert(itr != proposal_table.end(), "proposal not found.");
    eosio_assert(!itr->is_expired(), "proposal is already expired.");

    proposal_table.modify(itr, proposer, [&](auto& row) {
        row.expires_at = time_point_sec(now());
    });
}

// @abi
void forum::vote(
    const account_name voter,
    const account_name proposer,
    const name proposal_name,
    uint8_t vote,
    const string& vote_json
) {
    require_auth(voter);

    proposals proposal_table(_self, proposer);
    auto& row = proposal_table.get(proposal_name, "proposal_name does not exist under proposer's scope.");

    eosio_assert(!row.is_expired(), "cannot vote on an expired proposal.");

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
    const name proposal_name
) {
    require_auth(voter);

    proposals proposal_table(_self, proposer);
    auto& row = proposal_table.get(proposal_name, "proposal_name does not exist under proposer's scope.");

    if (row.is_expired()) {
        eosio_assert(row.can_be_cleaned_up(), "cannot unvote on an expired proposal within its grace period.");
    }

    votes vote_table(_self, proposer);

    auto index = vote_table.template get_index<N(byproposal)>();
    auto vote_key = compute_vote_key(proposal_name, voter);

    auto itr = index.find(vote_key);
    eosio_assert(itr != index.end(), "no vote exists for this proposal_name/voter pair.");

    vote_table.erase(*itr);
}

/**
 * This method does **not** require any authorization, here the reasoning for that.
 *
 * The method only allow anyone to clean a proposal if the proposal is either expired or does
 * not exist anymore. This exact case can only happen either by itself (the proposal as reach
 * its expiration time) or by the a proposer action (`expire`).
 *
 * In all cases, it's ok to let anyone clean the votes since there is no more "use"
 * for the proposal nor the votes.
 *
 * @abi
 */
void forum::clnproposal(
    const account_name proposer,
    const name proposal_name,
    uint64_t max_count
) {
    proposals proposal_table(_self, proposer);

    auto itr = proposal_table.find(proposal_name);
    eosio_assert(itr == proposal_table.end() || itr->can_be_cleaned_up(),
                 "proposal must not exist or be expired since at least 3 days prior clean up.");

    votes vote_table(_self, proposer);
    auto index = vote_table.template get_index<N(byproposal)>();

    auto vote_key_lower_bound = compute_vote_key(proposal_name, 0x0000000000000000);
    auto vote_key_upper_bound = compute_vote_key(proposal_name, 0xFFFFFFFFFFFFFFFF);

    auto lower_itr = index.lower_bound(vote_key_lower_bound);
    auto upper_itr = index.upper_bound(vote_key_upper_bound);

    uint64_t count = 0;
    while (count < max_count && lower_itr != upper_itr) {
        lower_itr = index.erase(lower_itr);
        count++;
    }

    // Let's delete the actual proposal if we deleted all votes and the proposal still exists
    if (lower_itr == upper_itr && itr != proposal_table.end()) {
        proposal_table.erase(itr);
    }
}

// @abi
void forum::post(
    const account_name poster,
    const string& post_uuid,
    const string& content,
    const account_name reply_to_poster,
    const string& reply_to_post_uuid,
    const bool certify,
    const string& json_metadata
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
void forum::unpost(const account_name poster, const string& post_uuid) {
    require_auth(poster);

    eosio_assert(post_uuid.size() > 0, "post_uuid should be longer than 0 character.");
    eosio_assert(post_uuid.size() < 128, "post_uuid should be shorter than 128 characters.");
}

// @abi
void forum::status(const account_name account, const string& content) {
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

/// Helpers

bool forum::has_votes_on_proposal_already(const account_name proposer, const name proposal_name) {
    votes vote_table(_self, proposer);
    auto index = vote_table.template get_index<N(byproposal)>();

    auto key_lower_bound = compute_vote_key(proposal_name, 0x0000000000000000);
    auto key_upper_bound = compute_vote_key(proposal_name, 0xFFFFFFFFFFFFFFFF);

    return index.lower_bound(key_lower_bound) != index.upper_bound(key_upper_bound);
}

void forum::update_status(
    statuses& status_table,
    const account_name account,
    const function<void(status_row&)> updater
) {
    auto itr = status_table.find(account);
    if (itr == status_table.end()) {
        status_table.emplace(account, [&](auto& row) {
            row.account = account;
            row.updated_at = time_point_sec(now());
            updater(row);
        });
    } else {
        status_table.modify(itr, account, [&](auto& row) {
            row.updated_at = time_point_sec(now());
            updater(row);
        });
    }
}

void forum::update_vote(
    votes& vote_table,
    const name proposal_name,
    const account_name voter,
    const function<void(vote_row&)> updater
) {
    auto index = vote_table.template get_index<N(byproposal)>();
    auto vote_key = compute_vote_key(proposal_name, voter);

    auto itr = index.find(vote_key);
    if (itr == index.end()) {
        vote_table.emplace(voter, [&](auto& row) {
            row.id = vote_table.available_primary_key();
            row.proposal_name = proposal_name;
            row.voter = voter;
            row.updated_at = time_point_sec(now());
            updater(row);
        });
    } else {
        index.modify(itr, voter, [&](auto& row) {
            row.updated_at = time_point_sec(now());
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

