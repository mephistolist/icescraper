# icescraper
A web spider written in Crystal

Right now I have issues parsing out the html tags around the urls:

$ crystal my_spider.cr
Extracted links:
<a class=gb1 href="https://www.google.com/imghp?hl=pt-BR&tab=wi">
 <a class=gb1 href="https://maps.google.com.br/maps?hl=pt-BR&tab=wl">
 <a class=gb1 href="https://play.google.com/?hl=pt-BR&tab=w8">
 <a class=gb1 href="https://www.youtube.com/?tab=w1">
 <a class=gb1 href="https://news.google.com/?tab=wn">
 <a class=gb1 href="https://mail.google.com/mail/?tab=wm">
 <a class=gb1 href="https://drive.google.com/?tab=wo">
 <a class=gb1 style="text-decoration:none" href="https://www.google.com.br/intl/pt-BR/about/products?tab=wh">
 <a href="http://www.google.com.br/history/optout?hl=pt-BR" class=gb4>
 <a target=_top id=gb_70 href="https://accounts.google.com/ServiceLogin?hl=pt-BR&passive=true&continue=https://www.google.com/&ec=GAZAAQ" class=gb4>
 <a href="https://www.google.com/setprefdomain?prefdom=BR&amp;prev=https://www.google.com.br/&amp;sig=K_3YzXbPceE-wAv1DmgaLXQ5ZtXl4%3D">
Failed to lookup hostname for <a class=gb1 href="https://www.google.com/imghp?hl=pt-BR&tab=wi">
Failed to lookup hostname for <a class=gb1 href="https://maps.google.com.br/maps?hl=pt-BR&tab=wl">
Failed to lookup hostname for <a class=gb1 href="https://play.google.com/?hl=pt-BR&tab=w8">
Failed to lookup hostname for <a class=gb1 href="https://www.youtube.com/?tab=w1">
Failed to lookup hostname for <a class=gb1 href="https://news.google.com/?tab=wn">
Failed to lookup hostname for <a class=gb1 href="https://mail.google.com/mail/?tab=wm">
Failed to lookup hostname for <a class=gb1 href="https://drive.google.com/?tab=wo">
Unhandled exception: Invalid URI: bad port at character 43 (URI::Error)
  from /usr/share/crystal/src/uri/uri_parser.cr:143:11 in 'parse_port'
  from /usr/share/crystal/src/uri/uri_parser.cr:125:18 in 'parse_host'
  from /usr/share/crystal/src/uri/uri_parser.cr:87:18 in 'parse_authority'
  from /usr/share/crystal/src/uri/uri_parser.cr:62:9 in 'parse_path_or_authority'
  from /usr/share/crystal/src/uri/uri_parser.cr:47:20 in 'parse_scheme'
  from /usr/share/crystal/src/uri/uri_parser.cr:32:9 in 'parse_scheme_start'
  from /usr/share/crystal/src/uri/uri_parser.cr:26:7 in 'run'
  from /usr/share/crystal/src/uri.cr:575:5 in 'parse'
  from /usr/share/crystal/src/http/client.cr:831:7 in 'exec'
  from /usr/share/crystal/src/http/client.cr:410:3 in 'get'
  from my_spider.cr:18:18 in 'crawl_page'
  from my_spider.cr:27:29 in 'crawl_page'
  from my_spider.cr:11:5 in 'crawl'
  from my_spider.cr:50:1 in '__crystal_main'
  from /usr/share/crystal/src/crystal/main.cr:129:5 in 'main_user_code'
  from /usr/share/crystal/src/crystal/main.cr:115:7 in 'main'
  from /usr/share/crystal/src/crystal/main.cr:141:3 in 'main'
  from /lib/x86_64-linux-gnu/libc.so.6 in '??'
  from /lib/x86_64-linux-gnu/libc.so.6 in '__libc_start_main'
  from /home/ph33r/.cache/crystal/crystal-run-my_spider.tmp in '_start'
  from ???

I'm also getting errors when a redirect is found:

$ crystal my_spider.cr
Failed to fetch https://google.com - 301
