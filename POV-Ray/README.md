# POV-Ray

レイトレーシングソフトウェアである [POV-Ray](http://www.povray.org/) を用いて 3DCG を作成した．

![Dropout](dropout.jpg)

## Challenges

ガラスなどの光表現の美しさに惹かれ，様々な形状・大きさの電球による表現をしたくなった．

大きさや形状・向きのランダム性（適切な長さ・大きさで吊るされること）や，配置のランダム性（ゴチャつき・電球同士の重なりを抑える）の実現に苦労した．
また，レンダリングに非常に時間がかかったので，視界外のオブジェクトを生成しないなどの工夫をしている．

内部のフィラメントや電球・ソケットの丸みなど，全てプリミティブな図形の組み合わせで実現している．


## Description

天井から吊るされたRGB3色の電球と，手前に置かれた電球の対比．
それぞれの光によって生じた影が，その補色になっている．

モチーフは『X-Men Origins: Wolverine』に登場した Chris Bradley の部屋．

![](https://static.wikia.nocookie.net/xmenmovies/images/7/71/Bradley.jpg/revision/latest?cb=20120113081642)
