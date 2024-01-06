# icescraper
A simple web spider written in Crystal. You can build with the following:

```$ crystal build icescraper.cr --release && strip icescraper```

The usage can be found with -h or with no arguments given:

```$ ./icescraper                                             
 .___                      _________                                               
|   |  ____   ____       /   _____/  ____ _______ _____   ______    ____ _______  
|   |_/ ___\_/ __ \      \_____  \ _/ ___ \_  __ \\__  \  \____ \ _/ __ \\_  __ \ 
|   |\  \___\  ___/      /        \\  \___ |  | \/ / __ \_|  |_> >\  ___/ |  | \/ 
|___| \___  >\___  >    /_______  / \___  >|__|   (____  /|   __/  \___  >|__|    
          \/     \/             \/      \/             \/ |__|         \/

Usage: icescraper -d example.com
    -h, --help                       Show help message
    -d, --domain DOMAIN              Specify a domain or host. Use http:// if no SSL is used.
```

If example.com or any domain is used, the spider will assume SSL is in use. If you happen to find a site with no SSL, http://example.com will need to be used with the -d option. 

If you let the program run a few minutes, you may find thousands of entries being generated. You can save its output to a file from the command-line like this:

```$ ./to_run -d google.com > log```

If you get duplicates after that you can sort only unique entries with the following:

```$ sort log | uniq -c | sort -nr```

Crystal did not have the ability to implement some of the features I wanted to use here at this time. Personally I just love the syntax, simplicity and speed that only Crystal brings to the table and wanted to make something with it. I may add more to this later, but for now its just an exersize in using Crystal.
