import re

EMPTY_STRING = ""

LUAU_GENERIC_PATTERN = re.compile("(<\w+(,\s*\w+)*>)+")
LUAU_TYPE_PATTERN = re.compile(":\s*((\w+|{})\s*\|*\s*((\w+|{}))*)(\??)")
LUAU_RETURN_FUNCTION_TYPE_PATTERN = re.compile(":\s*\(([^)]*)\)\s*->\s*\w+\??")
LUAU_CAST_PATTERN = re.compile("")

def read(file: str):
    content = ""

    with open(file, "r") as f:
        content = f.read()

    return content


def write(file: str, content: str):
    with open(file, "w") as f:
        f.write(content)


def luau2lua(content: str):
    luaContent = content
    luaContent = re.sub(LUAU_RETURN_FUNCTION_TYPE_PATTERN, EMPTY_STRING, luaContent)
    luaContent = re.sub(LUAU_GENERIC_PATTERN, EMPTY_STRING, luaContent)
    luaContent = re.sub(LUAU_TYPE_PATTERN, EMPTY_STRING, luaContent)
    return luaContent


def main():
    write("luau2lua.lua", luau2lua(read("nex.luau")))
    pass


if __name__ == "__main__":
    main()