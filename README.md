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
    -d, --domain DOMAIN              Specify a domain or host.
```

You can save its output to a file from the command-line like this:

```$ ./icescraper -d domain.com > log```
