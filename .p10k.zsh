he expansions:
    #
    #   Parameter             | Meaning
    #   ----------------------+---------------
    #   P9K_WIFI_SSID         | service set identifier, a.k.a. network name
    #   P9K_WIFI_LINK_AUTH    | authentication protocol such as "wpa2-psk" or "none"; empty if unknown
    #   P9K_WIFI_LAST_TX_RATE | wireless transmit rate in megabits per second
    #   P9K_WIFI_RSSI         | signal strength in dBm, from -120 to 0
    #   P9K_WIFI_NOISE        | noise in dBm, from -120 to 0
    #   P9K_WIFI_BARS         | signal strength in bars, from 0 to 4 (derived from P9K_WIFI_RSSI and P9K_WIFI_NOISE)
    
    ####################################[ time: current time ]####################################
    # Current time color.
    typeset -g POWERLEVEL9K_TIME_FOREGROUND=66
    # Format for the current time: 09:51:02. See `man 3 strftime`.
    typeset -g POWERLEVEL9K_TIME_FORMAT='%D{%H:%M:%S}'
    # If set to true, time will update when you hit enter. This way prompts for the past
    # commands will contain the start times of their commands as opposed to the default
    # behavior where they contain the end times of their preceding commands.
    typeset -g POWERLEVEL9K_TIME_UPDATE_ON_COMMAND=false
    # Custom icon.
    typeset -g POWERLEVEL9K_TIME_VISUAL_IDENTIFIER_EXPANSION=
    # Custom prefix.
    typeset -g POWERLEVEL9K_TIME_PREFIX='%246Fat '
    
    # Example of a user-defined prompt segment. Function prompt_example will be called on every
    # prompt if `example` prompt segment is added to POWERLEVEL9K_LEFT_PROMPT_ELEMENTS or
    # POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS. It displays an icon and orange text greeting the user.
    #
    # Type `p10k help segment` for documentation and a more sophisticated example.
    function prompt_example() {
        p10k segment -f 208 -i '⭐' -t 'hello, %n'
    }
    
    # User-defined prompt segments may optionally provide an instant_prompt_* function. Its job
    # is to generate the prompt segment for display in instant prompt. See
    # https://github.com/romkatv/powerlevel10k#instant-prompt.
    #
    # Powerlevel10k will call instant_prompt_* at the same time as the regular prompt_* function
    # and will record all `p10k segment` calls it makes. When displaying instant prompt, Powerlevel10k
    # will replay these calls without actually calling instant_prompt_*. It is imperative that
    # instant_prompt_* always makes the same `p10k segment` calls regardless of environment. If this
    # rule is not observed, the content of instant prompt will be incorrect.
    #
    # Usually, you should either not define instant_prompt_* or simply call prompt_* from it. If
    # instant_prompt_* is not defined for a segment, the segment won't be shown in instant prompt.
    function instant_prompt_example() {
        # Since prompt_example always makes the same `p10k segment` calls, we can call it from
        # instant_prompt_example. This will give us the same `example` prompt segment in the instant
        # and regular prompts.
        prompt_example
    }
    
    # User-defined prompt segments can be customized the same way as built-in segments.
    # typeset -g POWERLEVEL9K_EXAMPLE_FOREGROUND=208
    # typeset -g POWERLEVEL9K_EXAMPLE_VISUAL_IDENTIFIER_EXPANSION='⭐'
    
    # Transient prompt works similarly to the builtin transient_rprompt option. It trims down prompt
    # when accepting a command line. Supported values:
    #
    #   - off:      Don't change prompt when accepting a command line.
    #   - always:   Trim down prompt when accepting a command line.
    #   - same-dir: Trim down prompt when accepting a command line unless this is the first command
    #               typed after changing current working directory.
    typeset -g POWERLEVEL9K_TRANSIENT_PROMPT=off
    
    # Instant prompt mode.
    #
    #   - off:     Disable instant prompt. Choose this if you've tried instant prompt and found
    #              it incompatible with your zsh configuration files.
    #   - quiet:   Enable instant prompt and don't print warnings when detecting console output
    #              during zsh initialization. Choose this if you've read and understood
    #              https://github.com/romkatv/powerlevel10k#instant-prompt.
    #   - verbose: Enable instant prompt and print a warning when detecting console output during
    #              zsh initialization. Choose this if you've never tried instant prompt, haven't
    #              seen the warning, or if you are unsure what this all means.
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=verbose
    
    # Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k has been initialized.
    # For example, you can type POWERLEVEL9K_BACKGROUND=red and see your prompt turn red. Hot reload
    # can slow down prompt by 1-2 milliseconds, so it's better to keep it turned off unless you
    # really need it.
    typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
    
    # If p10k is already loaded, reload configuration.
    # This works even with POWERLEVEL9K_DISABLE_HOT_RELOAD=true.
    (( ! $+functions[p10k] )) || p10k reload
}

# Tell `p10k configure` which file it should overwrite.
typeset -g POWERLEVEL9K_CONFIG_FILE=${${(%):-%x}:a}

(( ${#p10k_config_opts} )) && setopt ${p10k_config_opts[@]}
'builtin' 'unset' 'p10k_config_opts'
