# 자바스크립트를 통한 지뢰찾기

-   [게임 플레이하기](https://chanminesweeper.netlify.app)

## HTML

-   html에는 최대한 기능을 배제하고 껍데기만 구현하였다.
    
    ```
    <!doctype html>
    <html lang="en" xmlns:th="http://www.thymeleaf.org">
    <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width">
      <title>지뢰찾기</title>
    </head>
    <body class='mainPage'>
    난이도를 선택하세요.
    <div class='frame'>
      <button diff='easy' class='selectDifficulty' id='btnMineEasy'>쉬움</button>
      <button diff='normal' class='selectDifficulty' id='btnMineNormal'>보통</button>
      <button diff='hard' class='selectDifficulty' id='btnMineHard'>어려움</button>
    </div>
    남은 폭탄 수 : <b id="mineRemain"></b>
    <div class='mineAppear' id="mineIn"></div>
    </body>
    </html>
    ```
    

## CSS

-   스타일 시트

```
table{ 
    border-collapse:collapse; 
}
td{
    border:1px solid black;
    width: 40px;
    height: 40px;
    text-align: center;
}

.frame{
    margin-bottom: 20px;
}
.mineCover{
    background-color:saddlebrown;
}
.selectDifficulty{
    border:1px solid skyblue;
    /* backgroud-color:rgba(0, 0, 0, 0); */
    color: skyblue;
    padding:5px;
    margin-top:15px;
}
.hard{
    color:red;
}
.normal{
    color: blueviolet;
}
.easy{
    color: green;
}
.mineFrame{
    margin-top:20px;
    display: inline-table;
    border:1px solid black;
    /* border-collapse: collapse; */
    color: black;
}
#btnMineEasy{
    margin-right:-4px;
}
#btnMineNormal{
    margin-left:-3px;
    margin-right:-4px;
}
#btnMineHard{
    margin-left:-3px;
}
```

## javascript

![](https://i.imgur.com/UCdMdlY.png)

### 최초 설정

자바스크립트 함수들을 실행하기 전에 기능의 최초 설정을 진행해 준다.

-   사용 기능
    -   javascript 변수 사용
    -   동적 바인딩
    -   오른쪽 키 메뉴 출력 비활성화 및 기능 변경
-   먼저 전역 변수들을 설정해 준다.
    -   const
        -   final 변수
    -   let
        -   변경 가능 변수
    -   var
        -   여러 번 선언 가능한 변수
            -   이 변수는 function내에서 지역적으로 사용하는 것이 나아서 전역에서 사용하지 않음.

```
// 난이도 선택을 진행해 줄 seldiff
const selDiff = document.getElementsByClassName('selectDifficulty');
// mineIne안에 지뢰찾기 게임이 들어갈 것이다.
const mineIn = document.getElementById('mineIn');
// 남아있는 폭탄 개수를 보여줄 mineRemain -> 실제 폭탄 개수가 아니라, 내가 매핑해 준 지뢰의 개수
const mineRemain = document.getElementById('mineRemain');
// 난이도는 쉬움 ~ 어려움
let difficulty = 0;

// 지뢰 매설, 지뢰 찾기에 DFS로 사용될 xMove, yMove이다.
// 참고로 0~3번 위치까지는 상하좌우, 4~7번 위치는 대각선이다.
const xMove = [0, 0, 1, -1, 1, -1, -1, 1];
const yMove = [1, -1, 0, 0, 1, -1, 1, -1];

// 2차원 배열을 통해 지뢰찾기의 값들이 저장될 mineMao
let mineMap;
// 실제 전체 지뢰 갯수 wholeMine
let wholeMine;
// 매핑 가능 지뢰 개수
let mappingMine;
```

-   초기 설정을 잡아 주기 위한 init 함수
    -   동적 바인딩
        -   javascript를 통해 만들어진 오브젝트에 이벤트를 바인딩 해 주는 기능이다.
    -   마우스 오른쪽 키 동작 시 기존에 메뉴 등장을 막고, 다른 함수를 실행하기.

```
function init(){
    // click관련 eventListner추가
    // selDiff는 난이도 설정용이다. 즉 addEventListner를 사용하여 "click"이 감지되면 clickColor 함수를 진행시켜 준다.
    for(var i=0; i<selDiff.length; i++){
        selDiff[i].addEventListener("click", clickColor);
    }

    // 지뢰 클릭 시 -> 동적 바인딩
    // 지뢰는 처음에 html으로 설정되지 않고, function동작으로 만들어진다.
    // 이 지뢰에 addEventListener를 선언해 주기 위해 동적 바인딩을 진행해 준다.
    document.addEventListener('click',function(event){
        if(event.target && event.target.className === "mineCheck mineCover"){
            // 현재 위치의 좌표를 받아서  find함수 진행하기
            var x = event.target.getAttribute("xLoc");
            var y = event.target.getAttribute("yLoc");
            find(x, y, 0);
        }
    });

    // 지뢰찾기 할때는 마우스 오른쪽키 눌렀을 때 contextmenu나오지 않게
    document.getElementById("mineIn").addEventListener(
        "contextmenu", event => event.preventDefault()
    );

    // 지뢰 매핑 함수
    // 마우스 오른쪽 키를 눌러 폭탄이 있는지, 모르겠는지, 되돌리기 를 진행하도록 한다.
    document.getElementById("mineIn").addEventListener(
        "mousedown", event => {
            if(event.button==2) {
                var x = event.target.getAttribute("xLoc");
                var y = event.target.getAttribute("yLoc");
                mapping(x, y);
            }
        }
    );
}
```

### 난이도 선택시 색상 변경 이벤트

-   사용 기능
    -   class동적 적용 및 해제
        -   미리 css가 적용되어 있는 class를 하나씩 적용시켜 주고, 다른 난이도 선택 시 기존 난이도에 적용된 class를 해제시켜 준다.

```
function clickColor(event){
    if(difficulty!=this.getAttribute("diff")){
        if(confirm('해당 난이도로 게임을 구성하시겠습니까?')){
            for(var i=0; i<selDiff.length; i++){
                var remover = selDiff[i].getAttribute("diff");
                selDiff[i].classList.remove(remover);
            }
            difficulty = this.getAttribute("diff");
            event.target.classList.add(difficulty);
            make(difficulty);
        }
    }
}
```

### 지뢰찾기 난이도 별 판 크기 설정 및 지뢰 수 결정

-   사용 기능
    -   javascript 이차원 배열 선언 -> 함수 호출부

```
function make(choise){
    var xFrame;
    var yFrame;
    switch(choise){
        case 'easy' : xFrame = 10; yFrame = 10; wholeMine = 41; break;
        case 'normal' : xFrame = 15; yFrame = 15; wholeMine = 90; break;
        case 'hard' : xFrame = 22; yFrame = 22; wholeMine = 195; break;
    }
    mappingMine = wholeMine;
    mineMap = Array.mineMaker(xFrame, yFrame, wholeMine);   // mineMaker를 통해 이차원 배열 mineMap에 지뢰 매설 및 안전지대 땅 설정
    frameMaker(xFrame, yFrame, mineMap);                    // 껍데기 만들기 함수
}
```

### 껍데기 만들기

-   사용 기능
    -   attribute 세팅하기
    -   class 설정 및 추가
    -   table동적구현
        -   td, tr 동적 삽입
    -   id성정
        -   id는 2차원 배열을 일직선으로 세워서 순서대로 값을 만들었다.

```
function frameMaker(xFrame, yFrame){

    var mineFrame = document.createElement("table");
    mineFrame.className = "mineFrame";

    for(var i=0; i<xFrame; i++){
        var tr = document.createElement("tr");
        for(var j=0; j<yFrame; j++){
            var td = document.createElement("td");
            td.setAttribute("xLoc", i);
            td.setAttribute("yLoc", j);
            td.id = (Number(i*xFrame)+Number(j));
            td.setAttribute("mineVal", mineMap[i][j]);
            td.className = "mineCheck";
            td.classList.add("mineCover");
            tr.append(td);
        }
        mineFrame.append(tr);
    }
    mineIn.innerText = "";        // 하나의 테두리를 만드려면 기존 테두리는 없어야 한다.
    mineIn.append(mineFrame);
    mineRemain.innerText = mappingMine;  // 매핑할 전체 지뢰 개수 
}
```

### 폭탄 만들기

-   사용 기술
    -   이차원 배열 생성 -> 함수 동작부
    -   javascript 난수(floor를 통한 정수만 사용)의 중복 제거
    -   지뢰찾기 지뢰 생성 및 안전지대 숫자 생성 로직
        -   현재 위치 기준 7방향 중 지뢰가 아닌 곳에 표시
            -   지뢰 : -1
            -   안전지대 : 0이상의 정수
                -   지뢰 -1 주변 장소가 -1이 아닐 시 +1

```
Array.mineMaker = function(m, n, boomb){
    var a, mineMap = [];
    for (var i=0; i<m; i++){
        a = [];
            for (var j=0; j<n; j++){
                a[j] = 0;
            }
        mineMap[i] = a;
    }       // 이차원 배열을 생성해준다.

    while(boomb>0){ // 모든 지뢰가 매설될 때 까지
        var x = Math.floor((Math.random())*m);
        var y = Math.floor((Math.random())*n);
        if(mineMap[x][y]!==-1){ // 해당 위치가 지뢰가 아닐 때만
            boomb--;            // 지뢰를 하나 매설했다.
            mineMap[x][y] = -1;
            for(var i=0; i<8; i++){
                var xTo = x+xMove[i];
                var yTo = y+yMove[i];
                if(xTo<0 || xTo>=m || yTo<0 || yTo>=n) continue;
                if(mineMap[xTo][yTo]===-1) continue;
                mineMap[xTo][yTo]++;
            }
        }
    }
    return mineMap;
};
```

### 폭탄 클릭 시

-   사용 기능
    -   안전 지대 클릭 시 DFS로직
        -   현재 위치가 안전지대라면 상하좌우에 DFS를 실행하여 지뢰가 아닌 곳은 open
    -   ID를 통한 위치 검색
    -   textContent를 통해 보여지는 텍스트의 값 받아오기
    -   지뢰 클릭 시 초기화 로직

```
function find(x, y, dfs){
    var xFrame = mineMap.length;
    var yFrame = mineMap[0].length;
    var nowLoc = document.getElementById(Number(x*xFrame)+Number(y));
    var nowCondition = nowLoc.textContent;

    if(nowCondition==="💣"){}
    else if(mineMap[x][y]>=0){
        if(mineMap[x][y]!=0) nowLoc.innerText = mineMap[x][y];
        mineMap[x][y] = -2;     // 체크 완료하면 -2로 하여 다시 못보게 -> boolean대체
        nowLoc.classList.remove("mineCover");
        for(var i=0; i<4; i++){
            var xTo = Number(x)+Number(xMove[i]);
            var yTo = Number(y)+Number(yMove[i]);
            if(xTo<0 || xTo>=xFrame || yTo<0 || yTo>=yFrame) continue;
            if(mineMap[xTo][yTo]===-1) continue;
            find(xTo, yTo, 1);
        }
    }else if(mineMap[x][y]===-1){
        alert("펑~ GAME OVER~~~~~");
        mineIn.innerText = '';
        for(var i=0; i<selDiff.length; i++){
            var remover = selDiff[i].getAttribute("diff");
            selDiff[i].classList.remove(remover);
        }
        difficulty = 0;
        mineRemain.innerText = "";
    }
}
```

### 지뢰 매핑하기

-   사용 기능
    -   현재 위치에 지뢰 매핑하기
    -   지뢰 매핑 시 매설 가능 지뢰 수 변경하기
    -   정확한 위치에 지뢰 매핑 시 정답 설정
    -   모든 지뢰가 정확히 매설되면 정답이라고 알려주기
        -   전체 지뢰 개수 0개, 매핑해야할 지뢰 개수 0개

```
// 지뢰 매핑
function mapping(x, y){
    var xFrame = mineMap.length;
    var nowLoc = document.getElementById(Number(x*xFrame)+Number(y));
    var nowCondition = nowLoc.textContent;
    // wholeMine 전체 폭탄
    if(nowCondition==="💣"){        // 폭탄 -> ? 로 변경
        if(mineMap[x][y] === -1) wholeMine++;     // 지금 위치가 폭탄 매설 위치가 맞았다면 
        mappingMine++;
        nowLoc.innerText = "❓";
    }else if(nowCondition==="❓"){  // ? -> 빈칸으로 변경
        nowLoc.innerText = "";
    }else if(nowCondition===""){    // 빈칸 -> 폭탄 매설
        if(mineMap[x][y] === -1) wholeMine--;     // 지금 위치가 폭탄 매설 위치가 맞았다면
        mappingMine--;
        nowLoc.innerText = "💣";
    }
    mineRemain.innerText = mappingMine;
    if(wholeMine===0 && mappingMine===0){
        if(confirm("Clear~ 다시 하시겠습니까?")){
            mineIn.innerText = '';
            for(var i=0; i<selDiff.length; i++){
                var remover = selDiff[i].getAttribute("diff");
                selDiff[i].classList.remove(remover);
            }
            difficulty = 0;
        }
    } 
}
```

### init

이제 뭐 이니셜 함수를 호출시켜 주기만 하면 된다.

`init();`

---

## 전체 코드 통합

```
<!doctype html>
<html lang="en" xmlns:th="http://www.thymeleaf.org">
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width">
    <title>지뢰찾기</title>
    <style>
        table{ 
            border-collapse:collapse; 
        }
        td{
            border:1px solid black;
            width: 40px;
            height: 40px;
            text-align: center;
        }

        .frame{
            margin-bottom: 20px;
        }
        .mineCover{
            background-color:saddlebrown;
        }
        .selectDifficulty{
            border:1px solid skyblue;
            /* backgroud-color:rgba(0, 0, 0, 0); */
            color: skyblue;
            padding:5px;
            margin-top:15px;
        }
        .hard{
            color:red;
        }
        .normal{
            color: blueviolet;
        }
        .easy{
            color: green;
        }
        .mineFrame{
            margin-top:20px;
            display: inline-table;
            border:1px solid black;
            /* border-collapse: collapse; */
            color: black;
        }
        #btnMineEasy{
            margin-right:-4px;
        }
        #btnMineNormal{
            margin-left:-3px;
            margin-right:-4px;
        }
        #btnMineHard{
            margin-left:-3px;
        }
    </style>
</head>
<body class='mainPage'>
난이도를 선택하세요.
<div class='frame'>
    <button diff='easy' class='selectDifficulty' id='btnMineEasy'>쉬움</button>
    <button diff='normal' class='selectDifficulty' id='btnMineNormal'>보통</button>
    <button diff='hard' class='selectDifficulty' id='btnMineHard'>어려움</button>
</div>
남은 폭탄 수 : <b id="mineRemain"></b>
<div class='mineAppear' id="mineIn"></div>
</body>
<script>
    // 난이도 선택을 진행해 줄 seldiff
    const selDiff = document.getElementsByClassName('selectDifficulty');
    // mineIne안에 지뢰찾기 게임이 들어갈 것이다.
    const mineIn = document.getElementById('mineIn');
    // 남아있는 폭탄 개수를 보여줄 mineRemain -> 실제 폭탄 개수가 아니라, 내가 매핑해 준 지뢰의 개수
    const mineRemain = document.getElementById('mineRemain');
    // 난이도는 쉬움 ~ 어려움
    let difficulty = 0;

    // 지뢰 매설, 지뢰 찾기에 DFS로 사용될 xMove, yMove이다.
    // 참고로 0~3번 위치까지는 상하좌우, 4~7번 위치는 대각선이다.
    const xMove = [0, 0, 1, -1, 1, -1, -1, 1];
    const yMove = [1, -1, 0, 0, 1, -1, 1, -1];

    // 2차원 배열을 통해 지뢰찾기의 값들이 저장될 mineMao
    let mineMap;
    // 실제 전체 지뢰 갯수 wholeMine
    let wholeMine;
    // 매핑 가능 지뢰 개수
    let mappingMine;

    // 기초 init함수
    function init(){
        // click관련 eventListner추가
        // selDiff는 난이도 설정용이다. 즉 addEventListner를 사용하여 "click"이 감지되면 clickColor 함수를 진행시켜 준다.
        for(var i=0; i<selDiff.length; i++){
            selDiff[i].addEventListener("click", clickColor);
        }

        // 지뢰 클릭 시 -> 동적 바인딩
        // 지뢰는 처음에 html으로 설정되지 않고, function동작으로 만들어진다.
        // 이 지뢰에 addEventListener를 선언해 주기 위해 동적 바인딩을 진행해 준다.
        document.addEventListener('click',function(event){
            if(event.target && event.target.className === "mineCheck mineCover"){
                // 현재 위치의 좌표를 받아서  find함수 진행하기
                var x = event.target.getAttribute("xLoc");
                var y = event.target.getAttribute("yLoc");
                find(x, y, 0);
            }
        });

        // 지뢰찾기 할때는 마우스 오른쪽키 눌렀을 때 contextmenu나오지 않게
        document.getElementById("mineIn").addEventListener(
            "contextmenu", event => event.preventDefault()
        );

        // 지뢰 매핑 함수
        // 마우스 오른쪽 키를 눌러 폭탄이 있는지, 모르겠는지, 되돌리기 를 진행하도록 한다.
        document.getElementById("mineIn").addEventListener(
            "mousedown", event => {
                if(event.button==2) {
                    var x = event.target.getAttribute("xLoc");
                    var y = event.target.getAttribute("yLoc");
                    mapping(x, y);
                }
            }
        );
    }

    // 난이도 선택 색상 변경 이벤트
    function clickColor(event){
        if(difficulty!=this.getAttribute("diff")){
            if(confirm('해당 난이도로 게임을 구성하시겠습니까?')){
                for(var i=0; i<selDiff.length; i++){
                    var remover = selDiff[i].getAttribute("diff");
                    selDiff[i].classList.remove(remover);
                }
                difficulty = this.getAttribute("diff");
                event.target.classList.add(difficulty);
                make(difficulty);
            }
        }
    }



    // 전체 폭탄찾기 관련 내용들을 만드는 make
    function make(choise){
        var xFrame;
        var yFrame;
        switch(choise){
            case 'easy' : xFrame = 10; yFrame = 10; wholeMine = 41; break;
            case 'normal' : xFrame = 15; yFrame = 15; wholeMine = 90; break;
            case 'hard' : xFrame = 22; yFrame = 22; wholeMine = 195; break;
        }
        mappingMine = wholeMine;
        mineMap = Array.mineMaker(xFrame, yFrame, wholeMine);   // mineMaker를 통해 이차원 배열 mineMap에 지뢰 매설 및 안전지대 땅 설정
        frameMaker(xFrame, yFrame, mineMap);                    // 껍데기 만들기 함수
    }

    // 껍데기 만들기
    function frameMaker(xFrame, yFrame){

        var mineFrame = document.createElement("table");
        mineFrame.className = "mineFrame";

        for(var i=0; i<xFrame; i++){
            var tr = document.createElement("tr");
            for(var j=0; j<yFrame; j++){
                var td = document.createElement("td");
                td.setAttribute("xLoc", i);
                td.setAttribute("yLoc", j);
                td.id = (Number(i*xFrame)+Number(j));
                td.setAttribute("mineVal", mineMap[i][j]);
                td.className = "mineCheck";
                td.classList.add("mineCover");
                tr.append(td);
            }
            mineFrame.append(tr);
        }
        mineIn.innerText = "";
        mineIn.append(mineFrame);
        mineRemain.innerText = mappingMine;
    }

    // 이차원 배열 만들기 - 폭탄 만들기
    Array.mineMaker = function(m, n, boomb){
        var a, mineMap = [];
        for (var i=0; i<m; i++){
            a = [];
                for (var j=0; j<n; j++){
                    a[j] = 0;
                }
            mineMap[i] = a;
        }       // 이차원 배열을 생성해준다.

        while(boomb>0){ // 모든 지뢰가 매설될 때 까지
            var x = Math.floor((Math.random())*m);
            var y = Math.floor((Math.random())*n);
            if(mineMap[x][y]!==-1){ // 해당 위치가 지뢰가 아닐 때만
                boomb--;            // 지뢰를 하나 매설했다.
                mineMap[x][y] = -1;
                for(var i=0; i<8; i++){
                    var xTo = x+xMove[i];
                    var yTo = y+yMove[i];
                    if(xTo<0 || xTo>=m || yTo<0 || yTo>=n) continue;
                    if(mineMap[xTo][yTo]===-1) continue;
                    mineMap[xTo][yTo]++;
                }
            }
        }
        return mineMap;
    };

    // 폭탄 클릭
    function find(x, y, dfs){
        var xFrame = mineMap.length;
        var yFrame = mineMap[0].length;
        var nowLoc = document.getElementById(Number(x*xFrame)+Number(y));
        var nowCondition = nowLoc.textContent;

        if(nowCondition==="💣"){}
        else if(mineMap[x][y]>=0){
            if(mineMap[x][y]!=0) nowLoc.innerText = mineMap[x][y];
            mineMap[x][y] = -2;     // 체크 완료하면 -2로 하여 다시 못보게
            nowLoc.classList.remove("mineCover");
            for(var i=0; i<4; i++){
                var xTo = Number(x)+Number(xMove[i]);
                var yTo = Number(y)+Number(yMove[i]);
                if(xTo<0 || xTo>=xFrame || yTo<0 || yTo>=yFrame) continue;
                if(mineMap[xTo][yTo]===-1) continue;
                find(xTo, yTo, 1);
            }
        }else if(mineMap[x][y]===-1){
            alert("펑~ GAME OVER~~~~~");
            mineIn.innerText = '';
            for(var i=0; i<selDiff.length; i++){
                var remover = selDiff[i].getAttribute("diff");
                selDiff[i].classList.remove(remover);
            }
            difficulty = 0;
            mineRemain.innerText = "";
        }
    }

    // 지뢰 매핑
    function mapping(x, y){
        var xFrame = mineMap.length;
        var nowLoc = document.getElementById(Number(x*xFrame)+Number(y));
        var nowCondition = nowLoc.textContent;
        // wholeMine 전체 폭탄
        if(nowCondition==="💣"){        // 폭탄 -> ? 로 변경
            if(mineMap[x][y] === -1) wholeMine++;     // 지금 위치가 폭탄 매설 위치가 맞았다면 
            mappingMine++;
            nowLoc.innerText = "❓";
        }else if(nowCondition==="❓"){  // ? -> 빈칸으로 변경
            nowLoc.innerText = "";
        }else if(nowCondition===""){    // 빈칸 -> 폭탄 매설
            if(mineMap[x][y] === -1) wholeMine--;     // 지금 위치가 폭탄 매설 위치가 맞았다면
            mappingMine--;
            nowLoc.innerText = "💣";
        }
        mineRemain.innerText = mappingMine;
        if(wholeMine===0 && mappingMine===0){
            if(confirm("Clear~ 다시 하시겠습니까?")){
                mineIn.innerText = '';
                for(var i=0; i<selDiff.length; i++){
                    var remover = selDiff[i].getAttribute("diff");
                    selDiff[i].classList.remove(remover);
                }
                difficulty = 0;
            }
        } 
    }

    init();
</script>
</html>
```
