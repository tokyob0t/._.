---@diagnostic disable:lowercase-global

rockspec_format = "3.0"

package = "somewm-config"
version = "0.1-1"

description = {
	summary = "Somewm config using fennel",
	license = "MIT",
}

source = {
	url = "file://src/",
}

dependencies = {
	"lua >= 5.1",
}

build_dependencies = {
	"fennel",
	"toml2lua",
	"color",
	"rubato",
}

build = {
	type = "command",
	build_command = [[
        SOMEWM_MODULES=$(find /usr/share/somewm/lua -printf '%P\n' \
            | sed 's|/|.|g; s|\.lua$||' \
            | tr '\n' ',' \
            | sed 's/,$//'
        )

        fennel --require-as-include \
            --add-fennel-path src/?.fnl \
            --add-macro-path src/?.fnlm \
            --lambda-as-fn \
            --no-metadata \
            --skip-include lgi,$SOMEWM_MODULES \
            --raw-errors \
            -c src/rc.fnl > rc.lua 
    ]],
}
