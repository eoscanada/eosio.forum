export CONTRACT=eosioforum

export CHARS_50="abcdefhijklmnopqrstuwxyabcdefhijklmnopqrstuwxy0123"
export CHARS_250="${CHARS_50}${CHARS_50}${CHARS_50}${CHARS_50}${CHARS_50}"
export CHARS_1250="${CHARS_250}${CHARS_250}${CHARS_250}${CHARS_250}${CHARS_250}"
export CHARS_6250="${CHARS_1250}${CHARS_1250}${CHARS_1250}${CHARS_1250}${CHARS_1250}"
export CHARS_13000="${CHARS_6250}${CHARS_6250}"
export CHARS_37500="${CHARS_13000}${CHARS_13000}${CHARS_6250}"

export EXPIRES_AT=`date -u -v+1d +"%Y-%m-%dT%H:%M:%S"`

print_config() {
    echo "Config"
    echo " Contract: ${CONTRACT}"
}

# usage: action_ok <action> <permission> <json>
action_ok() {
    info -n "Pushing OK action '$1 ($2)' ... "
    output=`cleos push action -f --json ${CONTRACT} $1 "${3}" --permission $2 2>&1`

    exit_code=$?
    if [[ $exit_code != 0 ]]; then
        error "failure (command failed, expecting success)"
        println $output
        exit $exit_code
    fi

    success "success"
}

# usage: action_ko <action> <permission> <json> <output_pattern>
action_ko() {
    info -n "Pushing KO action '$1 ($2)' ... "
    output=`cleos push action -f --json ${CONTRACT} $1 "${3}" --permission $2 2>&1`

    exit_code=$?
    if [[ $exit_code == 0 ]]; then
        error "('$4' KO) failure (action succeed but expected failure)"
        [[ $NO_OUTPUT != "y" ]] && println $output
        exit $exit_code
    fi

    if [[ ! $output =~ "$4" ]]; then
        error "('$4' KO) failure (message not matching)"
        println $output
        exit 1
    fi

    success "('$4' OK) success"
}

# usage: table_row <table> <scope> [<pattern> ...]
table_row() {
    info -n "Checking table '$1 ($2)' ... "
    output=`cleos get table -l 1000 ${CONTRACT} $2 $1 2>&1 | tr -d '\n' | sed 's/  */ /g'`

    exit_code=$?
    if [[ $exit_code != 0 ]]; then
        error "failure (retrieval failed)"
        println $output
        exit $exit_code
    fi

    shift; shift;

    for var in "$@"; do
        if [[ $var =~ ^! ]]; then
            if [[ $output =~ "${var:1}" ]]; then
                error "failure (rows matching '${var:1}', should not)"
                println $output
                exit 1
            fi

            success -n "(not '${var:1}' OK) "
        else
            if [[ ! $output =~ "$var" ]]; then
                error "failure (rows not matching '$var')"
                println $output
                exit 1
            fi

            success -n "('$var' OK) "
        fi
    done

    success "success"
}

BROWN='\033[0;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

msg() {
    if [[ $1 != "-n" ]]; then println $BLUE "${@}"; else shift; print $BLUE "${@}"; fi
}

info() {
    if [[ $1 != "-n" ]]; then println $BROWN "${@}"; else shift; print $BROWN "${@}"; fi
}

success() {
    if [[ $1 != "-n" ]]; then println $GREEN "${@}"; else shift; print $GREEN "${@}"; fi
}

error() {
    if [[ $1 != "-n" ]]; then println $RED "${@}"; else shift; print $RED "${@}"; fi
}

# usage: print $color [<messages> ...]
print() {
    color=$1; shift;

    printf "${color}${@}${NC}"
}

# usage: println $color [<messages> ...]
println() {
    print $@
    printf "\n"
}
