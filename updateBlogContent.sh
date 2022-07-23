docker compose up

sudo docker cp blog-amsf-1:/app/_site/. ../dists/ #  取出编译完毕的内容

sudo rsync -av --delete /home/iltti/amsf-blog/dists/. /var/www/html #  博客内容暂时先当首页

sudo systemctl restart apache2

sudo rm -rf ../dists/