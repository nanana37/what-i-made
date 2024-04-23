#include "colors.inc"
#include "shapes.inc"
#include "textures.inc"
#include "Woods.inc"
#include "stones.inc"
#include "glass.inc"
#include "metals.inc"

/* グローバル設定 */
global_settings {
    /* Radiosity */
    radiosity{
        // pretrace_start 0.04
        // pretrace_end 0.01
        // count 200
        // recursion_limit 3
        // nearest_count 10
        // error_bound 0.5
    }

    /* Photons(不使用) */
    //photons{spacing 0.02}
}

//--------------------------------------
/* カメラ */
camera {
    location <sqrt(200),-5,0>
    look_at <3,-3,0>
    angle 90

    /* Focal Blur */
    aperture 0.2    //ボケの量
    focal_point <2, -8, -2> //焦点位置
    blur_samples 30    //ボケの滑らかさ．上げると処理も重くなる
}

//---------------------------------
/* 色やテクスチャの設定 */

/* ガラスの色と光の色 */
#declare RedG=color rgbf<1, 0, 0, 0.8>;//透過
#declare GreenG=color rgbf<0, 1, 0, 0.8>;
#declare BlueG=color rgbf<0, 0, 1, 1, 0.8>;
#declare WhiteG=color rgbft<1, 1, 1, 0.5, 0.5>;//tで影の強度．
#declare WhiteFG=color rgbf<1, 1, 1, 0.6>;

/* 電球のガラス用.質感調整. */
#declare I_Glass =
   interior{
      ior 1.01  //屈折率
      caustics 2    //集光度合い
      fade_distance 0.01    //光の減衰距離と減衰率．影の形状に影響．
      fade_power 0.01
   }

/* 電球の表面に貼るテクスチャ. */
#macro T_Glass(clr)
texture {
    pigment{clr}
    //色付きの直接光を反射して白いガラスにも色がついてしまっていたので
    //ambientやdiffuseを消した．
    finish {
        ambient 0.0
        diffuse 0.0
        reflection 0.1
        phong 0.3
        phong_size 90
    }
}
#end

/* ガラス用マテリアル */
#macro myM_Glass(clr)
material{
    //カスタム.
    T_Glass(clr)
    interior{
        I_Glass
    }
    //少し白く曇らせる
    texture{
        pigment{rgbt<1, 1, 1, 0.9>}
    }
    //色がよりはっきりするように色を重ねる．
    T_Glass(clr)
}
#end

/* フロストガラス用マテリアル */
#macro myM_FGlass(clr)
material{
    texture{
        pigment{clr}
        finish{ambient 0.8}
    }
}
#end

//---------------------------
/* CSG作成 */
/* フィラメント*/
/* power: 0-2. 電気が通っているか否か及び白色光か否かを判定する. */
/* 0: 通電なし. 1: 通電かつ白色. 2: 通電かつ非白色. */
#macro Filament(power)
union{
    //外側の導入線
    union{
        object{
            cylinder{
                0, y*2.4, 0.01
            }
            rotate x*10
            translate z*0.03
        }
        object{
            cylinder{
                0, y*2.4, 0.01
            }
            rotate x*-10
            translate z*-0.03
        }
        pigment{Black}
    }
    //内側の管と金属線(アンカー)
    union{
        union{
            object{
                cylinder{
                    0, y*1.7, 0.1
                }
            }
            object{
                torus{
                    0.15, 0.06
                }
                translate y*1.65
            }
            material{M_Glass}
        }
        union{
            object{
                cylinder{
                    y*1.6, y*2.4, 0.005
                }
                rotate x*10
                translate z*-0.2
            }
            object{
                cylinder{
                    y*1.6, y*2.4, 0.005
                }
                rotate x*-10
                translate z*0.2
            }
            texture{
                Aluminum
            }
        }

    }
    //発光部分
    light_source{
        <0,2,0>
        #if (power = 2)
            White
        #end

        //Photons(不使用)
        // photons{reflection on refraction on}

        //光源をばね状に
        looks_like{
            union {
                #declare N=0;
                #while (N<10)
                    sphere {
                        <1, 0, 0>, 1
                        translate <1, 3*N, 0>
                        rotate y*360*N
                    }
                    #declare N = N + 0.01;
                #end
                //強度==0なら真っ黒.そうでなければ白く発光.
                #if (power = 0)
                    texture{pigment{Black}}
                #else
                    texture{finish{ambient 1} pigment{White*5}}
                #end
                rotate x*90
                scale 0.025
                translate z*-0.39
                translate y*0.3
            }
        }
    }
}
#end

/* 電球のガラス部分 */
/* clr: ガラスの色 */
#macro Bulb_Glass(clr)
    object{
        //膨らみつつ繋がるようにblob.
        blob{
            threshold 1
            sphere{
                <0, 3, 0>, 4, 1.4
            }
            cylinder{
                <0, 1, 0>, <0, 2, 0>, 1, 3
            }
            scale 1
        }
        myM_Glass(clr)
        //中空に.
        hollow on

        //Photons(不使用)
        // photons{target collect off reflection on refraction on}
    }
#end

/* 電球のガラス部分(〇おおきい) */
/* clr: ガラスの色 */
#macro Bulb_Glass2(clr)
    object{
        //膨らみつつ繋がるようにblob.
        blob{
            threshold 1
            sphere{
                <0, 4, 0>, 6, 1.4
            }
            cylinder{
                <0, 1, 0>, <0, 2, 0>, 1, 3
            }
            scale 1
        }
        myM_Glass(clr)
        //中空に.
        hollow on
    }
#end

/* フロストガラス球 */
/* clr: ガラスの色(基本WhiteFG) */
#macro Frost_Glass(clr)
    object{
        //膨らみつつ繋がるようにblob.
        blob{
            threshold 1
            sphere{
                <0, 3, 0>, 4, 1.4
            }
            cylinder{
                <0, 1, 0>, <0, 2, 0>, 1, 3
            }
            scale 1
        }
        //白のすりガラスっぽく.
        myM_FGlass(clr)
        //中空に.
        hollow on
        //表面が光るように．
        double_illuminate
    }
#end

/* 無として. objectの引数に何もないとエラーが出るため． */
#declare Nothing=
object{box{<0,0,0>,<1,1,1> pigment{rgbt<1,1,1,1>}} scale 0.00001}

/* 電球 */
/* num: 電球の形状. */
/* 0-6: 通常, 6-7: 大きい, 7-8: フロストガラス. */
/* clr: ガラス球の色. power: 通電等判定. */
#macro Bulb(num, clr, power)
    union{
        #switch (num)
        #range (0, 6)
            object{Bulb_Glass(clr)}
            object{Filament(power) scale<1, 1, 1.1>}
        #break
        #range (6, 7)
            object{Bulb_Glass2(clr)}
            object{Filament(power) scale<1, 1.5, 1.1>}
        #break
        #range (7, 8)
            object{Frost_Glass(WhiteFG)}
            object{Filament(power) scale<1, 1, 1.1>}
        #end
        union{
            //口金
            difference{
                cylinder{
                    <0, -0.4, 0> <0, 0.7, 0> 0.8
                }
                //ねじ
                #declare N=0;
                #while (N<4.4)
                object{
                    sphere{
                        <0, -0.5, 0>, 0.1
                    }
                    translate <1, N*0.25, 0>
                    rotate <0, 360*N, 0>
                    #declare N = N + 0.01;
                    scale 0.75
                }
                #end
                material{
                    texture{
                        Silver_Texture
                        finish{reflection 0}
                    }
                }
                scale 0.8
            }
            //電極部分
            object{
                cone{
                    <0, 0, 0> 1, <0, 1, 0> 2
                }
                pigment{
                    color Black
                }
                scale 0.2
                translate <0, -0.6, 0>
            }
            scale 0.9
        }
        rotate x*180
    }
#end

/* ソケット */
/* clr1: メインの色 */
/* clr2: カバーの色*/
#macro Socket(clr1, clr2)
union{
    //メイン
    union{
        difference{
            //丸みを出す
            blob{
                threshold 0.6
                sphere{
                    <0, -1.4, 0>, 1, 1
                }
                cylinder{
                    <0, 0, 0>, <0, 0.1, 0>, 1, 3
                }
                translate y*0
                scale 1
            }
            //sphereを消去
            cylinder{
                <0, -3, 0>, <0, -0.9, 0>, 2
                pigment{Clear}
            }
        }
        //差込部分
        difference{
            //穴をあける
            difference{
                cylinder{
                    <0, 0, 0>, <0, 1.5, 0>, 0.74
                }
                cylinder{
                    <0, 0, 0>, <0, 3, 0>, 0.6
                    texture{
                        Silver_Texture
                        finish{reflection 0}
                    }
                }
            }
            //ねじ
            #declare N=0;
            #while (N<4.4)
                object{
                    sphere{
                        <0, 1, 0>, 0.1
                    }
                    translate <0.83, N*0.25, 0>
                    rotate <0, 360*N, 0>
                    #declare N = N + 0.01;
                    scale 0.75
                    texture{
                        Silver_Texture
                        finish{reflection 0.5}
                    }
                }
            #end
        }
        //ケーブルの出る部分
        cylinder{
            <0, -0.8, 0>, <0, -0.9, 0>, 0.25
        }
        texture{
            pigment{clr1}
            finish{
                Dull
                reflection 0
            }
        }
    }
    //ケーブル
    object{
        cylinder{
            <0, -0.5, 0>, <0, -10, 0>, 0.2
        }
        pigment{clr2}
    }
    rotate x*180
    translate y*1
}
#end

//---------------------------
/* シーン内配置 */

/* 乱数生成準備. */
 #declare r0 = seed(12345);


/* 電球・ソケット生成準備.  */
/* num: 生成物を決める. */
/** 0-8: 電球とソケット, 8-9: ソケットのみ, 9-10: 生成なし. */
/* clr: ガラス球の色, power: 通電等判定. */
/* sclr1: ソケットの色, sclr2: カバーの色*/
#macro Bulb_S(num, clr, power, sclr1, sclr2)
    #switch (num)
    #range (0, 8)   //電球とソケットの生成.
    union{
        object{Bulb(num, clr, power) scale 1 rotate z*0}
        object{Socket(sclr1, sclr2) translate y*0}
        scale 1
    }
    #break
    #range (8, 9)   //ソケットのみ生成.
        object{Socket(sclr1, sclr2) translate y*0}
    #break
    #else   //生成なし.
        object{Nothing}
    #end
#end


/* 天井電球生成. */
#declare p=0;
#while (p < 200)    //x方向
    #declare q = -p;
    #declare d = max(3.5, p/8); //隣接しすぎないように. 奥ほど生成密度低下.
    #while (q < p)    //z方向
        object{
            Bulb_S(rand(r0)*10, WhiteG, 1, White*rand(r0), White*rand(r0))
            rotate y*180*rand(r0)
            translate <15-p + rand(r0)*6, 5 + rand(r0)*13, q + rand(r0)*(d-3)>
        }
        #declare q = q + d;
    #end
    #declare p = p + 10;
#end

/* 単色光源の位置 */
#declare Rpos = <-17, 4,-4>;
#declare Gpos = <-6, 4, -16>;
#declare Bpos = <-4, 4, 15>;

/* 固定生成 */
//床置き
//奥は小さく
object{Bulb(1, WhiteG, 0) scale 1 rotate y*20 rotate z*111 translate y*-8.5 rotate y*-50 translate z * -1.5} 
object{Bulb(1, WhiteG, 0) scale 0.6 rotate z*111 rotate y*90 translate y*-8.5 translate x*-18 translate z * -15}  
object{Bulb(1, WhiteG, 0) scale 0.6 rotate z*111 rotate y*50 translate y*-8.5 translate x*-15 translate z*8}
object{Bulb(1, WhiteG, 0) scale 0.6 rotate z*111 rotate y*50 translate y*-8.5 translate x*-25 translate z*25}  
object{Bulb(1, WhiteG, 0) scale 0.6 rotate z*111 rotate y*50 translate y*-8.5 translate x*-60 translate z*-20}

//ソケット単体
object{Socket(color<0.3, 0.3, 0.3>, White) translate <3, 2, -5>}

//テスト用
// object{Bulb_S(6, WhiteG, 1, White, color Red) rotate x*0 translate y*10 translate z*10}
// object{Bulb_S(10, WhiteG, 1, Brown, color Red) rotate x*0 translate <-8, 4, 0>}

// 色付き
object{Bulb_S(1, RedG, 2, Gray, Gray) scale 1.2 rotate y*60 translate Rpos}
object{Bulb_S(1, GreenG, 2, Gray, Gray) scale 1.2 rotate y*60 translate Gpos}
object{Bulb_S(1, BlueG, 2, Gray, Gray) scale 1.2 rotate y*20 translate Bpos}


// 天井
object{
    plane{
        y, 20
        pigment{Black}  //光を吸収
    }
}

// 床
object{
    plane{
        y, -9
    	texture{
    		pigment{rgbt<0.9,0.9,0.9,0.8>}
    		normal{
    			crackle 0.8 //模様として．
    		}
    		finish{reflection 0}}   //反射しすぎないように
	}
}

//-------------------------------------
/* 軸確認用 */

// light_source{<40,20,-40> color 2*White}

// object{ //x-axis
//    cylinder{<-50,0,0>,<50,0,0>,0.05}
//    pigment{color White}
// }
// object{ //y-axis
//    cylinder{<0,-50,0>,<0,50,0>,0.05}
//    pigment{color White}
// }
// object{ //z-axis
//    cylinder{<0,0,-50>,<0,0,50>,0.05}
//    pigment{color White}                                                             
// } 
// #macro Arrow(c, txt)
// union{
// 	object{
// 		cylinder{<0,0.5,0>, <0, 4, 0>, 0.2}
// 	}
// 	object{
// 		cone{<0,3,0> 1, <0, 5, 0> 0}
// 	}
// 	object{
// 		text{ttf "timrom.ttf", txt, 0.2, 0}
// 		translate<-0.4, 5, 0>
// 	}
// 	pigment{color c}
// }
// #end
// #macro triarrows(dx, dy, dz)
// union{
// 	object{
// 		sphere{<0, 0, 0>, 0.5}
// 		pigment{color White}
// 	}
// 	object{
// 		Arrow(Red, "X")
// 		rotate -90*z
// 	}
// 	object{
// 		Arrow(Green, "Y")
// 	}
// 	object{
// 		Arrow(Blue, "Z")
// 		rotate 90*x
// 	}	
// 	translate<dx, dy, dz>
// }
// #end

// triarrows(1,2,2)