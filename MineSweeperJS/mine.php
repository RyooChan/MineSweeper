<html>
<head>

<link rel="shortcut icon" href="#">

</head>
</html>

<!-- html부분 -->
<link rel="stylesheet" href="./mine.css" type="text/css" />
<div class = "whole">


    <table id="minetable">
     </table>
</div>


<script src="http://code.jquery.com/jquery.min.js"></script>
<script src="http://code.jquery.com/ui/1.11.4/jquery-ui.min.js"></script>
<script>

// 지뢰는 XY 각각 10줄로 만든다.
// 이중배열 선언
var mine = new Array(10);
for(let i=0; i<10; i++){
	mine[i] = new Array(10);
}

// 0으로 모두 초기화
for(let i=0; i<10; i++){
	for(let j=0; j<10; j++){
		mine[i][j] = 0;
	}
}

// 지뢰는 20개이고, (-1)이 지뢰이다.
for(let i=0; i<20; i++){
	// math.random은 소수점을 모두 포함하므로 정수로 나타내기 위해 내림해준다.
	let X = Math.floor((Math.random())*10);
	let Y = Math.floor((Math.random())*10);
	// 이미 존재하는 지뢰인 경우 -1, 지뢰는 20개니까 다시 시도하도록 i--.
	if(mine[X][Y] == -1)
		i--;
	else
		mine[X][Y] = -1;
}

// 지뢰를 기준으로 대각선, 상하좌우 7방향에 1씩 더해주면 지뢰찾기 틀이 완성될 것이다.
let Xmove = [1, 1, 1, 0, 0, -1, -1, -1];
let Ymove = [0, 1, -1, -1, 1, 0, 1, -1];

// 지뢰판을 벗어나지 않는 경우 근처에 지뢰가 있으면 그곳에 1씩 더하기.
for(let i=0; i<10; i++)
	for(let j=0; j<10; j++)
		if(mine[i][j] == -1)
			for(let k=0; k<8; k++)
				if((i+Xmove[k]>=0) && (i+Xmove[k]<10) && (j+Ymove[k]>=0) && (j+Ymove[k]<10) )
					if((mine[i+Xmove[k]][j+Ymove[k]] != -1))
						mine[i+Xmove[k]][j+Ymove[k]]++;
	
// 지뢰찾기 실제 동작 function이다. 
function checker(X, Y, a){
	// 지뢰이면 터지고 restart.
	if(mine[X][Y] == -1){
		alert("폭탄!! game over..");
		location.reload(true);
	}
	else	// 지뢰가 아니면 보여주기
		a.html(mine[X][Y]);
		//return mine[X][Y];
}

// html이 모두 준비되면 사용 가능
$(document).ready(function(){
	// minetable에 위 html table에 나타낼 정보를 기입할 예정이다.
	var minetable = "";
	// 10개의 X축 -> tr
	for(let i=0; i<10; i++){
		minetable += "<tr align='center'>";
		// 각 X축의 10개의 Y축 -> td (근데 사실 XY반대임)
		for(let j=0; j<10; j++){
			// X-val, Y-val에 값들을 넣어준다. 이는 나중에 attr을 통해 받아올 수 있다.
			minetable += "<td X-val="+i+" Y-val="+j+"  class='location'></td>";
		}
		minetable += "</tr>";
	}
		
	// minetable에 해당 javascript의 minetable변수를 html로 보내준다.
	$("#minetable").html(minetable);	

	// 마우스 오른쪽 왼쪽을 구현하기 위해 mousedown사용
	$(".location").mousedown(function(){ 
		// event button에 따라서 시행
		var btn=event.button;
		// 만약 오른쪽 버튼이 눌리면
		if(btn==2){
			//순서대로 !, ?, null -> 
			if($(this).html()=="!")
				$(this).html("?");
			else if($(this).html()=="?")
				$(this).html("");
			else
				$(this).html("!");
			// 오른쪽 버튼의 경우 false를 return해서 뒤에를 진행하지 않도록 한다.
			return false;
		}
		
		// 버튼의 위치를 Jquery로 둘러싼다. 이 a를 위의 checker function에서 사용하기 위해서이다.
		var a = $(this);
		// X-val, Y-val의 값들을 받아온다.
		getX = $(this).attr("X-val");
		getY = $(this).attr("Y-val");
		// 지뢰표시가 있으면 눌리지 않게 한다.
		// 지뢰표시가 없는 경우 checker를 진행해 준다.
		if(a.html()!="!")
		var status = checker(getX, getY, a);
		
	}); 


}); 

// 마우스 왼쪽 버튼이 눌릴 때 menu가 나오지 않도록 설정했다.
$(document).on('contextmenu', function() {
  return false;
});

</script>

