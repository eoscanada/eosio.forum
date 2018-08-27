#pragma once

#include <algorithm>
#include <string>

#include <eosiolib/eosio.hpp>
#include <eosiolib/time.hpp>

using eosio::const_mem_fun;
using eosio::indexed_by;
using eosio::name;
using eosio::time_point_sec;
using std::function;
using std::string;

class forum : public eosio::contract {
    public:
        forum(account_name self)
        :eosio::contract(self)
        {}
        // @abi
        void propose(
            const account_name proposer,
            const name proposal_name,
            const string& title,
            const string& proposal_json,
            const time_point_sec& expires_at
        );

        // @abi
        void expire(const account_name proposer, const name proposal_name);

        // @abi
        void vote(
            const account_name voter,
            const account_name proposer,
            const name proposal_name,
            uint8_t vote_value,
            const string& vote_json
        );

        // @abi
        void unvote(
            const account_name voter,
            const account_name proposer,
            const name proposal_name
        );

        // @abi
        void clnproposal(
            const account_name proposer,
            const name proposal_name,
            uint64_t max_count
        );

        /// @param certify - under penalty of perjury the content of this post is true.
        // @abi
        void post(
            const account_name poster,
            const string& post_uuid,
            const string& content,
            const account_name reply_to_poster,
            const string& reply_to_post_uuid,
            const bool certify,
            const string& json_metadata
        );

        // @abi
        void unpost(const account_name poster, const string& post_uuid);

        // @abi
        void status(const account_name account, const string& content);

    private:
        // 3 days in seconds (Computation: 3 days * 24 hours * 60 minutes * 60 seconds)
        constexpr static uint32_t GRACE_PERIOD_IN_SECONDS = 3 * 24 * 60 * 60;

        // 6 months in seconds (Computation: 6 months * average days per month * 24 hours * 60 minutes * 60 seconds)
        constexpr static uint32_t SIX_MONTHS_IN_SECONDS = (uint32_t) (6 * (365.25 / 12) * 24 * 60 * 60);

        static uint128_t compute_vote_key(const name proposal_name, const account_name voter) {
            return ((uint128_t) proposal_name.value) << 64 | voter;
        }

        struct proposal_row {
            name                  proposal_name;
            string                title;
            string                proposal_json;
            time_point_sec        created_at;
            time_point_sec        expires_at;

            auto primary_key()const { return proposal_name.value; }
            bool is_expired() const { return time_point_sec(now()) >= expires_at; }
            bool can_be_cleaned_up() const { return time_point_sec(now()) > (expires_at + GRACE_PERIOD_IN_SECONDS);  }
        };
        typedef eosio::multi_index<N(proposal), proposal_row> proposals;

        struct vote_row {
            uint64_t               id;
            name                   proposal_name;
            account_name           voter;
            uint8_t                vote;
            string                 vote_json;
            time_point_sec         updated_at;

            auto primary_key() const { return id; }
            uint128_t by_proposal() const { return forum::compute_vote_key(proposal_name, voter); }
        };
        typedef eosio::multi_index<
            N(vote), vote_row,
            indexed_by<N(byproposal), const_mem_fun<vote_row, uint128_t, &vote_row::by_proposal>>
        > votes;

        struct status_row {
            account_name         account;
            string               content;
            time_point_sec       updated_at;

            auto primary_key() const { return account; }
        };
        typedef eosio::multi_index<N(status), status_row> statuses;

        bool has_votes_on_proposal_already(const account_name proposer, const name proposal_name);

        void update_status(
            statuses& status_table,
            const account_name account,
            const function<void(status_row&)> updater
        );

        void update_vote(
            votes& vote_table,
            const name proposal_name,
            const account_name voter,
            const function<void(vote_row&)> updater
        );

        // Do not use directly, use the VALIDATE_JSON macro instead!
        void validate_json(
            const string& payload,
            size_t max_size,
            const char* not_object_message,
            const char* over_size_message
        );
};
