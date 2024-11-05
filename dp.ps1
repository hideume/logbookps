#$global:dt=@()
<#リストのセットを分かり易くする
#$j：設定するリスト
#$n: リストの数
#$m1 結合させるリスト1の最初と最後
$m2 2番目の結合させるリスト1の最初と最後(省略可能）
#>
function setlist($j,$n,$m1,$m2=(-1,-1)){
    $rtnv=@()
    for($i=0;$i -lt $n;$i++){
        if($m1[0]..$m1[1] -contains $i -or $m2[0]..$m2[1] -contains $i){
            if($m1[1] -eq $i){
                $tp=""
                for($i2=$m1[0];$i2 -le $m1[1];$i2++){
                    $tp+=$j[$i2]
                }
                $rtnv+=$tp
            }
            if($m2[1] -eq $i){
                $tp=""
                for($i2=$m2[0];$i2 -le $m2[1];$i2++){
                    $tp+=$j[$i2]
                }
                $rtnv+=$tp
            }
        }else{
            $rtnv+=$j[$i]
            #echo "$i $rtnv"
        }       
    }
    #echo ("rtnv= $($rtnv -join ",")")
    return $rtnv
}


#-------------main start -------------
$dbg=$true
$dt=@()
$input|% {if($_.length -gt 1){ $dt+=$_  }}
#$dt.length
#$dt[0]
#$dt[1]
if($dbg){for ($ii=0;$ii -lt $dt.length;$ii++){echo "$ii $($dt[$ii])"} }
#$global:btls = New-Object System.Collections.ArrayList
$btls = @()
$i=0
#
if($dbg){echo "------------航空戦-----------"}
$flg=$false
$btlskk=@()
#ここは航空戦ブロック
do {
    $i++
} until ($dt[$i] -match "残り|開幕")
if($dt[$i] -match "開幕"){
}else{
    $i++
    do {
        $tmp=$dt[$i].split(" ")
        if($tmp.length -gt 4){
            $tmp = ($tmp[0]+$tmp[1]),$tmp[2],$tmp[3]
        }
        $btlskk+=,$tmp
        $i++
    } until ($dt[$i] -match "敵軍: 攻撃に参加した艦")
    if($dbg){foreach($c in $btlskk){
        "$($c[0])/$($c[1])/$($c[2])"
    }}
}
#航空戦ブロックここまで
#ここから開幕ブロックのダメージ部
if($dbg){echo "------------開幕-----------"}
$km=@();$km2=@()
do {
    $i++
} until ($dt[$i] -match "^ダメージ")
$i++
do {
    $km+=$dt[$i]
    $i++
} until ($dt[$i] -match "^敵軍ダメージ")
$i=$i+3
do {
    $km2+=$dt[$i]
    $i++
    #echo $i
} until ($dt[$i] -match "敵軍攻撃")
$btlskai=@()
$t1=$km.split(" ")
$t2=$km2.split(" ")
echo "t1="+$t1
echo "t2="+$t2
for($i1=0 ;$i1 -lt $m1.length; $i1++){
    for($i2=0 ; $i2 -lt $m2.length; $i2++){
        if($t1[$i1][0] -eq $t2[$i2][0]){
            $t1[$i1][4]=$t1[$i2][2]
        }
    }
}
$t1[4]=$t2[2]
#echo $t3
$btls_kai+=,$t1
if($dbg){echo $btls_kai}
#>
#ここのブロックは通常の交戦履歴を収拾
#$iを上記の続きとして使う
for ($i;$i -lt $dt.length;$i++){
    if( $dt[$i] -match "^自軍 "){
        $tmp=$dt[$i].split(" ")
        if( $tmp[2] -eq "→"){
            if($tmp.length -eq 9){
                #"11"+$($tmp -join ",")
                $btls+=,$tmp
            }elseif($tmp.length -eq 10){
                #敵にもflagshipがあるばあい
                #"12 $(($tmp[0],$tmp[1],$tmp[2],$tmp[3],($tmp[4]+$tmp[5]),$tmp[6],$tmp[7],$tmp[8]) -join "/")"
                #$btls+=,($tmp[0],$tmp[1],$tmp[2],$tmp[3],($tmp[4]+$tmp[5]),$tmp[6],$tmp[7],$tmp[8])
                $btls+=,$(setlist $tmp 10 (4,5) )
            }
        }elseif($tmp[3] -eq "→"){
            if($tmp.length -eq 10){
            #heywood LE改とかを1つにする
                #"21 $(($tmp[0],($tmp[1]+$tmp[2]),$tmp[3],$tmp[4],$tmp[5],$tmp[6],$tmp[7],$tmp[8],$tmp[9]) -join "/")"
                #$btls+=,($tmp[0],($tmp[1]+$tmp[2]),$tmp[3],$tmp[4],$tmp[5],$tmp[6],$tmp[7],$tmp[8],$tmp[9])
                $btls+=,$(setlist $tmp 10 (1,2))
            }elseif($tmp.length -eq 11){
            #さらに敵軍にflagshipがある場合
                #"22 $(($tmp[0],($tmp[1]+$tmp[2]),$tmp[3],$tmp[4],($tmp[5]+$tmp[6]),$tmp[7],$tmp[8],$tmp[9],$tmp[10]) -join "/")"
                #$btls+=,($tmp[0],($tmp[1]+$tmp[2]),$tmp[3],$tmp[4],($tmp[5]+$tmp[6]),$tmp[7],$tmp[8],$tmp[9],$tmp[10])
                $btls+=,$(setlist $tmp 11 (1,2) (5,6))
            }
        }elseif($tmp[4] -eq "→"){
            if($tmp.length -eq 11){
            #samuel B.ro MkIIとかを1つにする
                "31 $(($tmp[0],($tmp[1]+$tmp[2]+$tmp[3]),$tmp[4],$tmp[5],$tmp[6],$tmp[7],$tmp[8],$tmp[9],$tmp[10]) -join "/")"
                #$btls+=,($tmp[0],($tmp[1]+$tmp[2]+$tmp[3]),$tmp[4],$tmp[5],$tmp[6],$tmp[7],$tmp[8],$tmp[9],$tmp[10])
                $btls+=,$(setlist $tmp 11 (1,3))
            }elseif($tmp.length -eq 12){
            #さらに敵軍にflagshipがある場合
               "#32 $(($tmp[0],($tmp[1]+$tmp[2]+$tmp[3]),$tmp[4],$tmp[5],($tmp[6]+$tmp[7]),$tmp[8],$tmp[9],$tmp[10],$tmp[11]) -join "/")"
                #$btls+=,($tmp[0],($tmp[1]+$tmp[2]+$tmp[3]),$tmp[4],$tmp[5],($tmp[6]+$tmp[7]),$tmp[8],$tmp[9],$tmp[10],$tmp[11])
                $btls+=,$(setlist $tmp 12 (1,3) (6,7))
            }
        }
    }
}
if($dbg){echo "--------------砲撃(1,2)---------------"}
if($dbg){for ($ii=0;$ii -lt $btls.length ;$ii++){
    echo "$ii $($btls[$ii] -join "/") "
}}
#敵軍名,自軍名1、dmg1,自軍名2、dmg2,自軍名3、dmg3,自軍名4、dmg4
#初期設定
$reslt=@()
$reslt+=,@(0,1,1,1,1,1,1,1,1,1,1,1)
$reslt+=,@(0,1,1,1,1,1,1,1,1,1,1,1)
$reslt+=,@(0,1,1,1,1,1,1,1,1,1,1,1)
$reslt+=,@(0,1,1,1,1,1,1,1,1,1,1,1)
$reslt+=,@(0,1,1,1,1,1,1,1,1,1,1,1)
$reslt+=,@(0,1,1,1,1,1,1,1,1,1,1,1)

#btlsの形式 行no,自軍(0,自軍名(1,->(2,敵軍(3,敵軍名(4,type(5,??(6,dmg(7.dmgu結果(8
# 
for ($ii=0;$ii -lt $btlskk.length  ;$ii++){
    $eno=[int]$btlskk[$ii][0].substring(0,1) - 1
    $reslt[$eno][0]=$btlskk[$ii][0]
    $reslt[$eno][1]=$btlskk[$ii][2]
}
# 開幕のデータは 味方名(0,->(1,敵名(2,dmg(3,dmg結果(4
for ($ii=0;$ii -lt $btls_kai.length  ;$ii++){
    $eno=[int]$btls_kai[$ii][2].substring(0,1) - 1
    $reslt[$eno][0]=$btls_kai[$ii][2]
    $reslt[$eno][2]=$btls_kai[$ii][0]
    $reslt[$eno][3]=$btls_kai[$ii][4]
}
for ($ii=0;$ii -lt $btls.length  ;$ii++){
    #echo $btls[$ii][4]
    $eno=[int]$btls[$ii][4].substring(0,1) - 1
    if($reslt[$eno][4] -eq 1){
        $reslt[$eno][0]=$btls[$ii][4]
        $reslt[$eno][4]=$btls[$ii][1] 
        $reslt[$eno][5]=$btls[$ii][7] -eq "" ? "ミス":$btls[$ii][7]
    }elseif($reslt[$eno][6] -eq 1){
        $reslt[$eno][0]=$btls[$ii][4]
        $reslt[$eno][6]=$btls[$ii][1]
        $reslt[$eno][7]=$btls[$ii][7] -eq "" ? "ミス":$btls[$ii][7]
    }elseif($reslt[$eno][8] -eq 1){
        $reslt[$eno][0]=$btls[$ii][4]
        $reslt[$eno][8]=$btls[$ii][1]
        $reslt[$eno][9]=$btls[$ii][7] -eq "" ? "ミス":$btls[$ii][7]
    }elseif($reslt[$eno][10] -eq 1){
        $reslt[$eno][0]=$btls[$ii][4]
        $reslt[$eno][10]=$btls[$ii][1]
        $reslt[$eno][11]=$btls[$ii][7] -eq "" ? "ミス":$btls[$ii][7]
    }
}
for ($i=0;$i -le 5 ;$i++){
    #echo "$($reslt[$i][0,1,2,3,4,5,6,7,8])"
    [pscustomobject]@{敵名=$reslt[$i][0];航空戦=$reslt[$i][1];
                        開幕=$reslt[$i][2];Hit0=$reslt[$i][3];
                            味方1=$reslt[$i][4];Hit1=$reslt[$i][5];
                            味方2=$reslt[$i][6];Hit2=$reslt[$i][7];
                            味方3=$reslt[$i][8];Hit3=$reslt[$i][9];
                            味方4=$reslt[$i][10];Hit4=$reslt[$i][22]
    }
}
