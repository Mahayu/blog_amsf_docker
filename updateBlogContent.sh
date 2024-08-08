sudo docker compose up
sudo docker cp blog_amsf_docker-amsf-1:/app/_site/. ../dists/ #  取出编译完毕的内容
sudo rsync -av --delete ../dists/. /var/www/html #  博客内容暂时先当首页
ls /var/www/html
sudo nginx -s reload
#sudo systemctl restart apache2
sudo rm -rf ../dists/