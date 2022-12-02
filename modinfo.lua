name = "AI Plays DST"
version = "1"
author = "AI Plays DST"
description = [[Yes!]]
forumthread = ""
id = "aiplaysdst"

configuration_options = {
    {
        name = "OptName",
        label = "Some Option",
        options = {
            {
                description = "Selection 1",
                data = 1
            },
            {
                description = "Selection 2 (default)",
                data = 2
            },
            {
                description = "Selection 3",
                data = 3
            },
            {
                description = "Selection 4",
                data = 4
            }
        },
        default = 2
    },
}

api_version = 6
dont_starve_compatible = true
dont_starve_together_compatible = true
reign_of_giants_compatible = false
icon = "modicon.tex" --preview image
icon_atlas = "modicon.xml"