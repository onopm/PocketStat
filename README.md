#PocketStat - PocketIO を使ったリソース表示ツール

短時間間隔で、サーバリソースをグラフ表示するためのツールです。  
デフォルトでは、vmstat(iostat) interval 1 を実行しつつ、その結果より
ブラウザ上でグラフ化します。

以下で確認しています。  

- mac
- linux (Debian 6)
- solaris (Solaris11 + SolarisStudio 12.3)


## 使い方

CPANより各種モジュールをインストールし、pocketstat.pl を実行してください。

$ cpanm --installdeps .  
$ ./pocketstat.pl -p 5000 -l 300

  - -p ポート.  デフォルト 5000
  - -l グラフ化するデータ長.  デフォルト 300秒


### perlbrew, cpanm を使ったことがない人向けモジュールインストール方法

PocketStatをdownload、展開後に以下を実行し、cpanmスクリプトを実行します。

$ cd pocketstat/  
$ curl -LO http://xrl.us/cpanm  
$ perl cpanm --installdeps -Lextlib .  
...  
<== Installed dependencies for .. Finishing.  
$  
  -Lextlib を指定することで、extlib以下にcpanモジュールをインストールします。  
    (root 権限は必要ありません。)


#### Solaris

system-perl(/usr/bin/perl)を使用する場合は、SolarisStudioをセットアップし
Sun C コンパイラを使ってください。

gccでmakeしたperlを使用する(perlbrewを使うと楽です)場合は、SolarisStudioは
必要ありません。



## 過去データのグラフ表示とか

データの保存などは考えていません。  
長期データの保存は、素直に CloudForecast や GrowthForecast を使いましょう。

なお、pocketstat.pl は growthforecast.pl を参考にさせて頂きました。

