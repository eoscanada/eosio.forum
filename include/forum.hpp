#pragma once

#include <algorithm>
#include <string>

#include <eosiolib/eosio.hpp>
#include <eosiolib/crypto.h>

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
        void propose(
            const account_name proposer,
            const name proposal_name,
            const string& title,
            const string& proposal_json
        );

        // @abi
        void unpropose(const account_name proposer, const name proposal_name);

        // @abi
        void status(const account_name account, const string& content);

        // @abi
        void vote(
            const account_name voter,
            const account_name proposer,
            const name proposal_name,
            const string& proposal_hash,
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
        void cleanvotes(
            const account_name proposer,
            const name proposal_name,
            uint64_t max_count
        );

    private:
        static uint8_t hex_char_to_uint8(char character) {
            const int x = character;

            return ((x <= 57) ? x - 48 : ((x <= 70) ? (x - 65) + 0x0a : (x - 97) + 0x0a));
        }

        static void proposal_hash_to_checksum256(const string& proposal_hash, checksum256* checksum) {
            const char* characters = proposal_hash.c_str();
            for (uint64_t i = 0; i < proposal_hash.size(); i += 2) {
                checksum->hash[i / 2] = 16 * hex_char_to_uint8(characters[i]) + hex_char_to_uint8(characters[i + 1]);
            }
        }

        static void compute_proposal_hash(const string& proposal_title, const string& proposal_json, checksum256* hash) {
            const string content = proposal_title + proposal_json;
            sha256(content.c_str(), content.size(), hash);
        }

        static uint128_t compute_vote_key(const name proposal_name, const account_name voter) {
            return ((uint128_t) proposal_name.value) << 64 | voter;
        }

        struct proposal {
            name           proposal_name;
            string         title;
            string         proposal_json;

            auto primary_key()const { return proposal_name.value; }
        };
        typedef eosio::multi_index<N(proposal), proposal> proposals;

        struct statusrow {
            account_name   account;
            string         content;
            time           updated_at;

            auto primary_key() const { return account; }
        };
        typedef eosio::multi_index<N(status), statusrow> statuses;

        struct voterow {
            uint64_t               id;
            name                   proposal_name;
            string                 proposal_hash;
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
