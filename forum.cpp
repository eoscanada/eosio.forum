#include <eosiolib/eosio.hpp>

#include <string>

using eosio::name;

class forum : public eosio::contract {
    public:
        forum(account_name self)
        :eosio::contract(self)
        {}
        /// @param certify - under penalty of perjury the content of this post is true.
        // @abi
        void post(const account_name account, const std::string& post_uuid, const std::string& title, const std::string& content,
                  const account_name reply_to_account, const std::string& reply_to_post_uuid, const bool certify, const std::string& json_metadata) {
            require_auth(account);
            eosio_assert(title.size() < 128, "title should be less than 128 characters long.");

            eosio_assert(content.size() > 0, "content should be more than 0 characters long.");
            eosio_assert(content.size() < 1024 * 1024 * 10, "content should be less than 10 KB long.");

            eosio_assert(post_uuid.size() > 0, "post_uuid should be longer than 3 characters.");
            eosio_assert(post_uuid.size() < 128, "post_uuid should be shorter than 128 characters.");

            if (reply_to_account == 0) {
              eosio_assert(reply_to_post_uuid.size() == 0, "If reply_to_account is not set, reply_to_post_uuid should not be set.");
            } else {
                eosio_assert(title.size() == 0, "If the post is a reply, there should not be a title.");
                eosio_assert(is_account(reply_to_account), "reply_to_account must be a valid account.");
                eosio_assert(reply_to_post_uuid.size() > 0, "reply_to_post_uuid should be longer than 3 characters.");
                eosio_assert(reply_to_post_uuid.size() < 128, "reply_to_post_uuid should be shorter than 128 characters.");
            }

            if (json_metadata.size() != 0) {
                eosio_assert(json_metadata[0] == '{', "json_metadata must be a JSON object (if specified).");
                eosio_assert(json_metadata.size() < 8192, "json_metadata should be shorter than 8192 bytes.");
            }
        }

        // @abi
        void remove(const account_name account, const std::string& post_uuid) {
            require_auth(account);
            eosio_assert(post_uuid.size() > 0, "Post UUID should be longer than 0 characters.");
            eosio_assert(post_uuid.size() < 128, "Post UUID should be shorter than 128 characters.");
        }

        // @abi
        void vote(const account_name voter, const std::string& proposition, const std::string& proposition_hash, const std::string& vote_value, const std::string& json_metadata) {
            require_auth(voter);
            eosio_assert(proposition.size() < 256, "Proposition reference should be less than 256 characters long.");
            eosio_assert(proposition_hash.size() < 128, "proposition_hash should be less than 128 characters long.");
            eosio_assert(vote_value.size() > 0, "Vote value should be at least 1 character.");
            eosio_assert(vote_value.size() < 128, "Vote value should be less than 128 characters long.");

            if (json_metadata.size() != 0) {
                eosio_assert(json_metadata[0] == '{', "json_metadata must be a JSON object (if specified).");
                eosio_assert(json_metadata.size() < 8192, "json_metadata should be shorter than 8192 bytes.");
            }
        }
};

EOSIO_ABI( forum, (post)(remove)(vote) )
