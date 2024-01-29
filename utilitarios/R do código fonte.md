sudo apt install gfortran  
sudo apt-get install libreadline-dev 
sudo apt-get install libx11-dev  
sudo apt-get install libxext-dev libxt-dev 
sudo apt-get install libbz2-dev
sudo apt-get install liblzma-dev
sudo apt-get install libpcre2-dev  
sudo apt-get install libcurl4-openssl-dev
sudo apt-get update; sudo apt-get install default-jre 
%%
nao sei se essa parte precisa, até porque deu erro
sudo apt-get update; sudo apt-get install build-essential; sudo apt-get build-dep r-base 
%%
tar -zxvf R-4.3.2.tar.gz 
cd R-4.3.2/  
 ./configure  --enable-R-shlib --with-cairo (n acho q esse ultimo seja relevante e vou ignorar, mas se der erro no png de novo, é por causa disso)
make   
sudo make install 