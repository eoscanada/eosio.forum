#pragma once

#include <algorithm>
#include <string>

#include <eosiolib/eosio.hpp>

using eosio::const_mem_fun;
using eosio::indexed_by;
using eosio::name;
using std::function;
using std::string;

class forum : public eosio::contract {
    public:
        forum(account_name self)
        :eosio::contract(self)
        {}
        /// @param certify - under penalty of perjury the content of this post is true.
        // @abi
        void post(
            const account_name poster,
            const std::string& post_uuid,
            const std::string& content,
            const account_name reply_to_poster,
            const std::string& reply_to_post_uuid,
            const bool certify,
            const std::string& json_metadata
        );

        // @abi
        void unpost(const account_name poster, const std::string& post_uuid);

        // @abi
        void propose(
            const account_name proposer,
            const name proposal_name,
            const std::string& title,
            const std::string& proposal_json
        );

        // @abi
        void unpropose(const account_name proposer, const name proposal_name);

        // @abi
        void status(const account_name account, const std::string& content);

        // @abi
        void vote(
            const account_name voter,
            const account_name proposer,
            const name proposal_name,
            const std::string& proposal_hash,
            uint8_t vote_value,
            const std::string& vote_json
        );

        // @abi
        void unvote(
            const account_name voter,
            const account_name proposer,
            const name proposal_name,
            const std::string& proposal_hash
        );

        // @abi
        void cleanvotes(
            const account_name proposer,
            const name proposal_name,
            uint64_t max_count
        );

    private:
        static uint128_t compute_vote_key(const name proposal_name, const account_name voter) {
            return ((uint128_t) proposal_name.value) << 64 | voter;
        }

        struct proposal {
            name           proposal_name;
            std::string    title;
            std::string    proposal_json;

            auto primary_key()const { return proposal_name.value; }
        };
        typedef eosio::multi_index<N(proposal), proposal> proposals;

        struct statusrow {
            account_name   account;
            std::string    content;
            time           updated_at;

            auto primary_key() const { return account; }
        };
        typedef eosio::multi_index<N(status), statusrow> statuses;

        struct voterow {
            uint64_t               id;
            name                   proposal_name;
            account_name           voter;
            uint8_t                vote;
            string                 vote_json;
            time                   updated_at;

            auto primary_key() const { return id; }
            uint64_t by_proposal() const { return proposal_name; }
            uint128_t by_vote_key() const { return forum::compute_vote_key(proposal_name, voter); }
        };
        typedef eosio::multi_index<
            N(vote), voterow,
            indexed_by<N(proposal), const_mem_fun<voterow, uint64_t, &voterow::by_proposal>>,
            indexed_by<N(votekey), const_mem_fun<voterow, uint128_t, &voterow::by_vote_key>>
        > votes;

        void update_status(
            statuses& status_table,
            const account_name account,
            const function<void(statusrow&)> updater
        );

        void update_vote(
            votes& vote_table,
            const name proposal_name,
            const account_name voter,
            const function<void(voterow&)> updater
        );

        // Do not use directly, use the VALIDATE_JSON macro instead!
        void validate_json(
            const string& payload,
            size_t max_size,
            const char* not_object_message,
            const char* over_size_message
        );
};
