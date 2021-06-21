<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.util.*" %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=0.8">
<title>LookUp B/L</title>
<link rel = "icon" href = "<%=request.getContextPath()%>/img/favicon.png">
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/lookupBL.css" type="text/css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<script>
	
	var temp = 0; //테이블 동적으로 추가할때 select태그 안 id에 넣을 변수 (변수를 넣지않으면 다른행의 년도를 바꿀때 원치않는 다른것도 바뀜. 더 좋은방법 찾아보기)
	
	//B/L추가 버튼을 누르면 동적으로 행을 삽입하기위한 함수
	function addRow(){
		// Javascript로 테이블에 행 추가 방법
	 	var tableData = document.getElementById('TblAttach');
		
	 	if(tableData.rows.length > 10) { //기존에 있던 thead행 생각해야됨
			alert("10개를 초과할수없습니다.");
			return;
		}
	 	
	 	//마지막행에 새로운 행 삽입
	 	var row = tableData.insertRow(tableData.rows.length );
	 	
	 	//열 생성
	 	var cell0 = row.insertCell(0);
	 	var cell1 = row.insertCell(1);
	 	var cell2 = row.insertCell(2);
	 	
	 	//열에 html 삽입
	 	cell0.innerHTML = '<td><input type="checkbox" name="chkbox" class = "indexCheckBox"></td>';
		cell1.innerHTML += '<td><select id = "selectNum'+temp+'" name = "blYear"></select></td>';
		
		//selectd값을 현재 년도에 맞추기위해 만듬
	 	let today = new Date();   
	 	let currentYear = today.getFullYear(); // 년도
	 		
		var str ="";//셀렉트 코드 들어갈 변수
		for(var i = currentYear; i > currentYear - 4; i--) {
			if(i == currentYear) {
				str += '<option value = "'+ i+'" selected="selected">' +i + '</option>';
			} else {
				str += '<option value = "'+ i+'">' +i + '</option>';
			}
		}
		
		document.getElementById('selectNum'+temp++).innerHTML = str; //셀렉트 태그안에 삽입
		cell2.innerHTML = '<input type = "text" placeholder="HOUSE B/L번호를 입력하세요" name="blNum" size="30" required="required" maxlength="30">';	
	}
	
	//동적으로 생성된 행을 삭제하기위한 함수
	function delRow(){
	   //
	    var tableData = document.getElementById('TblAttach');
	   
	   //가져온 테이블의 길이만큼 반복문 돌면서 행의 첫셀(열) 첫자식노드(체크박스) 체크여부 를 확인함
	    for(var i = 2 ; i < tableData.rows.length; i++ ){
	        var chkbox = tableData.rows[i].cells[0].childNodes[0].checked;
	        
	        //체크박스가 체크돼있으면 삭제
	        if(chkbox){
	            tableData.deleteRow(i);
	            i--;
	        }
	    } 
	}
	//전체선택함수
	function selectAll(selectAll)  {
		const checkboxes = document.getElementsByName('chkbox');
		
		checkboxes.forEach((checkbox) => {
		checkbox.checked = selectAll.checked;
		})
	}

</script>   
</head>
<body>
<div class = "container indexContaine">
	<jsp:include page="./inc/home.jsp"></jsp:include>
	<section class = "section">
		<h1>LOOKUP B/L</h1>
		<h6>B/L 일괄조회</h6>
	</section>
	<section class = "section2">
		<div class="center">
			<img src = "<%=request.getContextPath()%>/img/mainImg2.png">
		</div>
		<form action = "<%=request.getContextPath()%>/lookupResult.jsp" method = "post" >
		<table class = "table-bordered buttons" id="TblAttach">			
			<thead>
				<tr class= "indexHeader">
					<th>선택</th>
					<th>B/L 년도</th>
					<th>B/L 번호</th>
				</tr>
			</thead>
			<tbody>		 
					<tr>
						<td></td>
						<td>
							<!-- selectd값을 현재 년도에 맞추기위해 만듬 -->
							<select	name = "blYear">
							<%
								Calendar cal = Calendar.getInstance();
								int currentYear = cal.get(Calendar.YEAR);							
								
								for(int i = currentYear; i > currentYear - 4; i--) {
									if(i == currentYear) {
									%>
										<option value = "<%=i%>" selected="selected"><%=i%></option>
									<%
									} else {
									%>
										<option value = "<%=i%>"><%=i%></option>
									<%
									}
								}
							%>
							</select>
						</td>
						<td><input type = "text" placeholder="HOUSE B/L번호를 입력하세요" name="blNum" size="30" required="required" maxlength="30"></td>
					</tr>
			</tbody>
			
		</table>
		<br>
		<!-- 체크박스 전체선택 -->
		<div class = "center">
			<input type='checkbox' name='chkbox' value='selectall' onclick='selectAll(this)'/>전체선택
		</div>
		<br>
		<!-- 동적으로 행 추가 삭제하는 버튼 -->
		<div class = "center">		
			<input type='button' class="btn btn-info" value="선택 B/L삭제" onClick="delRow();"/>
			<input type='button' class="btn btn-info" value="B/L 추가" onClick="addRow();"/>
			
		</div>
		<br>
		<!-- 입력된 비엘번호 조회하는 버튼 -->
		<div class = "center">
			<button type = "submit" class="btn btn-info">조회</button>
		</div>
	</form>
	</section>
	<footer class= "footer">
		<div>
			<p>© 필밍 pilming 2021. All Rights Reserved.</p> 
		</div>
	</footer>
</div>
</body>
</html>