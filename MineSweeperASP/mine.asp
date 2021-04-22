<title>
    지뢰찾기
</title>

<html>
<head>

<link rel="shortcut icon" href="#">
<link rel="stylesheet" href="./mine.css" type="text/css" />


</head>
</html>


<div class="mineWhole">
    <h1> 지뢰찾기 </h1>

' 길이 높이를 입력받아 지뢰찾기를 실시한다
    <div class="mineMaker">
        판　의 길이를 입력하세요 <input type="number" id="Xin" placeholder="최대 50" ><br>
        판　의 높이를 입력하세요 <input type="number" id="Yin" placeholder="최대 20"><br>
        지뢰의 개수를 입력하세요 <input type="number" id="minein"   ><br>
        <button id="makerConfirm">입력</button>
    </div>

    <div class="mineHere">
        지 뢰 찾 기
        <table id="mineTable"> 
        </table>
    </div>



</div>

<script type="text/javascript" src="/v15/js/jquery-3.2.1.min.js"></script>
<script>
    // 해당 Xin, Yin과 지뢰의 수 minein
    let Xin = document.getElementById('Xin');
    let Yin = document.getElementById('Yin');
    let minein = document.getElementById('minein');
    
    // 위, 아래, 양, 옆을 이동하며 확인할 move들이다.
    let Xmove = [1, 1, 1, 0, 0, -1, -1, -1];
    let Ymove = [0, 1, -1, -1, 1, 0, 1, -1];

    $(document).ready(function(){
        // 지뢰찾기 만들기가 눌리는 경우
        $("#makerConfirm").click(function(){
            let setMine;
            // 먼저 길이 높이 지뢰의 수 등을 판단한다.
            if(Xin.value == ""){
                alert("길이를 입력해주세요.");
                Xin.focus();
                return false;
            }
            if(Yin.value >= 21){
                alert("높이를 줄여주세요.");
                Yin.focus();
                return false;
            }
            if(Xin.value >= 51){
                alert("길이를 줄여주세요.");
                Yin.focus();
                return false;
            }

            if(Yin.value == ""){
                alert("높이를 입력해주세요.");
                Yin.focus();
                return false;
            }
            
            if(minein.value == ""){
                alert("지뢰의 개수를 입력해주세요.");
                Xin.focus();
                return false;
            }
            else if(minein.value >= Xin.value*Yin.value ){  // X*Y가 최대 지뢰의 개수이다.
                alert("지뢰의 개수가 너무 많습니다.");
                Xin.focus();
                return false;
            }
            // 문제가 없으면 비동기 처리를 이용해 tableMaker에서 지뢰를 세팅한다.
            $.ajax({
                 type: "POST"
                ,url : "tableMaker.asp"
                ,data: {
                          "Xin"      : Xin.value
                        , "Yin"      : Yin.value
                        , "minein"   : minein.value
                    }
                ,success : function(data) {
                    if(data) {
                            $("#mineTable").html(data);   // data를 무사히 받으면 minetable의 html변경
                    }
                }
            });

        });

        // 오른쪽 왼쪽 판단을 위한 mousedown, 추가로 Ajax로 받은 html은 밑의 방법으로 스크립트를 진행해야 한다.
        $(document).on('mousedown', '.location', function(){
            var btn = event.button;
            var coordinate = $(this);
            var XVal = coordinate.attr("XVal");
            var YVal = coordinate.attr("YVal");
            var checker = coordinate.attr("checker");
             // 왼쪽 버튼이 눌리는 경우
            if(btn==2){
                 // 지뢰:★, 알수없음:??, 다시 클릭시 초기화
                if(coordinate.html()=="★")            
                    coordinate.html("??");
                else if(coordinate.html()=="??")       
                    coordinate.html("");
                else if(coordinate.html()=="")         
                    coordinate.html("★");
            }
            else{   // 오른쪽 클릭의 경우
                if(coordinate.html()=="★")    // 지뢰이면 눌리지 않는다.
                    return false;
                else
                    minecheck(XVal, YVal, 0); // 지뢰 표시가 없는 경우 minecheck실행
            }
        });
    });
    
    //    지뢰 유무를 판단하는 function
    function minecheck(X, Y, extend){
        var target =  $("#"+(X-1)+"aa"+(Y-1));    // id를 통해 위치를 받아온다. 이것을 사용하여 주변 위치도 판단할 것이다.
        // 0을 누르는 경우 주변을 찾아서 0이거나 지뢰가 아니면 주변을 열어준다. extend는 내가 누른 곳인지, 혹은 0에 의해 파악하는 곳인지 알기 위한 변수이다.
        if(target.attr("mineVal") == -1 && extend==0) {   // 지뢰이고, 내가 눌렀을 경우
            alert("폭탄이 터졌어요 game over");
            location.reload(true);          // 다시 게임하기
        }
        if(target.attr("mineVal") == 0){      // 0인 경우
            target.html(target.attr("mineVal"));    // target의 값을 숫자로 바꿔준다.
                if(target.attr("checker")==0 )    // 재귀함수를 이용하여 주변 수들을 파악하는데, 한번 확인한 경우를 다시 보면 무한루프가 생기므로 이를 방지하기 위해 checker를 사용함
                    for(var i=0; i<8; i++){
                        target.attr("checker", 1);    // 아직 확인 안한곳은
                        minecheck(parseInt(X)+parseInt(Xmove[i]), parseInt(Y)+parseInt(Ymove[i]), 1);   // 8방향을 봐준다. 이곳에서는 JS가 오류가 나는 부분을 버리기에 사용하지 않았지만, 이후 다른 언어로 포팅을 진행할 떄에는 배열을 진행할 때에 주변의 값이 table을 벗어나지 않도록 설정해야 할 것이다.
                    }
        }
        else{     // 0도 지뢰도 아닌 경우 보여주면 된다. 
            target.attr("checker", 1);    // 무한루프 방지를 위한 checker의 변경
            target.html(target.attr("mineVal"));
        }
    }

    // 오른쪽 버튼 클릭 시 문제 발생 가능성  
    $(document).on('contextmenu', function(){
        return false;
    });

</script>
