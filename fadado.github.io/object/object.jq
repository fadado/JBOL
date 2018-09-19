module {
    name: "object",
    description: "Object utilities",
    namespace: "fadado.github.io",
    author: {
        name: "Joan Josep Ordinas Rosa",
        email: "jordinas@gmail.com"
    }
};

# unknown value for index?
def unknown($x): #:: object|(string) => boolean
    has($x) and .[$x] == null
;

# vim:ai:sw=4:ts=4:et:syntax=jq
