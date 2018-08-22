#include <algorithm>
#include <cinttypes>
#include <iostream>
#include <sstream>

using namespace std;

typedef unsigned __int128 uint128_t;

static bool starts_with(const string& value, const string& prefix);
static string to_upper(string& value);
static string to_hex(uint64_t value);
static string hex_string_to_little_endian(const string& value);
static char char_to_symbol( char c );
static uint64_t string_to_name( const char* str );

int main(int argument_count, const char** arguments) {
    if (argument_count < 2) {
        cerr << "usage: vote_key proposal_name voter" << endl;
        return 1;
    }

    auto proposal_name = arguments[1];
    auto voter = arguments[2];

    auto proposal_name_value = string_to_name(proposal_name);
    auto voter_valuer = string_to_name(voter);

    auto voter_key = (((uint128_t) proposal_name_value) << 64 | (uint128_t) voter_valuer);

    cout << "Proposal name '"
         << proposal_name
         << "' (dec " << proposal_name_value
         << ", hex " << to_hex(proposal_name_value)
         << ")" << endl;

    cout << "Voter '"
         << voter
         << "' (dec " << voter_valuer
         << ", hex " << to_hex(voter_valuer)
         << ")" << endl;

    char buffer[256];
    sprintf(buffer, "%016" PRIx64 "%016" PRIx64,(uint64_t)(voter_key>>64),(uint64_t)voter_key);
    string voter_key_string = string(buffer);

    string voter_key_big_endian_hex = to_upper(voter_key_string);
    string voter_key_little_endian_hex = hex_string_to_little_endian(voter_key_big_endian_hex);
    cout << "Voter key" << endl
         << " Big endian: 0x" << voter_key_big_endian_hex << endl
         << " Little endian: 0x" << voter_key_little_endian_hex << endl;

    return 0;
}

static bool starts_with(const string& value, const string& prefix) {
    return value.rfind(prefix, 0) == 0;
}

static string to_hex(uint64_t value) {
    std::stringstream stream;
    stream << "0x" << std::hex << value;
    auto hex_string = stream.str();

    return to_upper(hex_string);
}

static string hex_string_to_little_endian(const string& value) {
    if (value.size() <= 0) return "";

    std::stringstream stream;
    int offset = 0;
    if (starts_with(value, "0x")) {
        stream << "0x";
        offset = 2;
    }

    for (int i = value.size() - offset; i > 0; i -= 2) {
        stream << value[i - 2] << value[i - 1];
    }

    auto hex_string = stream.str();

    return to_upper(hex_string);
}

static string to_upper(string& value) {
    std::transform(value.begin(), value.end(), value.begin(), ::toupper);
    return value;
}

static char char_to_symbol(char c) {
    if (c >= 'a' && c <= 'z') return (c - 'a') + 6;
    if (c >= '1' && c <= '5') return (c - '1') + 1;

    return 0;
}

static uint64_t string_to_name(const char* payload) {
    uint32_t length = 0;
    while (payload[length]) ++length;

    uint64_t value = 0;
    for (uint32_t i = 0; i <= 12; ++i) {
        uint64_t c = 0;
        if (i < length && i <= 12) c = uint64_t(char_to_symbol(payload[i]));

        if (i < 12) {
            c &= 0x1f;
            c <<= 64 - 5 * (i + 1);
        } else {
            c &= 0x0f;
        }

        value |= c;
    }

    return value;
}
