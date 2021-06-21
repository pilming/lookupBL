<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "javax.xml.parsers.DocumentBuilderFactory" %>
<%@ page import = "javax.xml.parsers.DocumentBuilder" %>
<%@ page import = "lookupBL.*" %>
<%@ page import = "java.util.*" %>
<%@ page import = "customs.vo.*" %>
<%@ page import = "java.text.SimpleDateFormat" %>
<%@ page import = "org.w3c.dom.Document" %>
<%@ page import = "org.w3c.dom.Element" %>
<%@ page import = "org.w3c.dom.Node" %>
<%@ page import = "org.w3c.dom.NodeList" %>

<!DOCTYPE html>
<html>
<head>
<link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/lookupBL.css" type="text/css">
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.5.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.16.0/umd/popper.min.js"></script>
<script src="https://maxcdn.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>
<meta charset="UTF-8">
<title>LookUp Result</title>
<link rel = "icon" href = "<%=request.getContextPath()%>/img/favicon.png">

<script>
	var temp = 0;
	function deleteDiv(num) {
	  const div = document.getElementById('my_div'+num);
	  
	  div.remove();
	} 
	
	function addRow(){
		// Javascript로 테이블에 행 추가 방법
	 	var tableData = document.getElementById('TblAttach');
	 	var prevTableCnt =  document.getElementsByClassName("prevTable").length;
		if(tableData.rows.length + prevTableCnt >= 10) {
			alert("10개를 초과할수없습니다.");
			return;
		}
		var row = tableData.insertRow(tableData.rows.length );
	 	
	 	var cell0 = row.insertCell(0);
	 	var cell1 = row.insertCell(1);
	 	var cell2 = row.insertCell(2);
	 	
	 	let today = new Date();   

	 	let currentYear = today.getFullYear(); // 년도
	 	
	 	
	 	cell0.innerHTML = '<td><input type="checkbox" name="chkbox" class = "checkBox"></td>';
		cell1.innerHTML += '<td><select id = "selectNum'+temp+'" name = "blYear"></select></td>';
		var str ="";
		for(var i = currentYear; i > currentYear - 4; i--) {
			if(i == currentYear) {
				str += '<option value = "'+ i+'" selected="selected">' +i + '</option>';
			} else {
				str += '<option value = "'+ i+'">' +i + '</option>';
			}
		}
		
		document.getElementById('selectNum'+temp++).innerHTML = str;
		cell2.innerHTML = '<input type = "text" placeholder="HOUSE B/L번호를 입력하세요" name="blNum" size="30" required="required" maxlength="30">';	
	}
	
	function delRow(){
	   // javascript를 사용한 방법
	    var tableData = document.getElementById('TblAttach');
	    for(var i = 0 ; i < tableData.rows.length; i++ ){
	        var chkbox = tableData.rows[i].cells[0].childNodes[0].checked;
	        
	        if(chkbox){
	            tableData.deleteRow(i);
	            i--;
	        }
	    } 
	}
	function selectAll(selectAll)  {
		const checkboxes = document.getElementsByName('chkbox');
		
		checkboxes.forEach((checkbox) => {
		checkbox.checked = selectAll.checked;
		})
	}
</script>
</head>
<body>
<div class = "container resultContainer">
	<jsp:include page="./inc/home.jsp"></jsp:include>
	<section class = "section">
		<h1>조회결과</h1>
		<h6>B/L 일괄조회</h6>
	</section>
<%
	request.setCharacterEncoding("utf-8");//한글깨짐방지
	//비엘번호 수집
	String[] blNum = request.getParameterValues("blNum");
	String[] blYear = request.getParameterValues("blYear");
	//값 디버깅
	if(blNum == null || blYear == null) {
		System.out.println("검색할게 없습니다.");
		response.sendRedirect(request.getContextPath()+"/index.jsp");
		return;
	}
	//사용할 비엘 번호, 년도가 들어가 리스트
	ArrayList<String> blNumList = new ArrayList<>();
	ArrayList<String> blYearList = new ArrayList<>();
	for(int i = 0; i < blNum.length; i++) {
		//공백제거
		blNum[i] = blNum[i].replaceAll(" ", "");
		blNum[i] = blNum[i].replaceAll("\\p{Z}", "");
		
		//구분문자 있는지 체크
		String[] tempBl = blNum[i].split(",|/|-"); //스플릿한 문자열이 들어갈 임시배열

		//구분문자가 있을경우
		if(tempBl.length >1) {
			for(int j =0; j < tempBl.length; j++) {
				if(j == 0) { //첫 기준 문자
					blNumList.add(tempBl[j]);
					blYearList.add(blYear[i]);
				} else { //추가적인 번호가 있으면		
					int cuttingLength = tempBl[j].length();
					System.out.println(cuttingLength + " : 자를 길이");
					System.out.println(tempBl[0] + " : 0번째 문자열, 기준문자열");
					tempBl[j] = tempBl[0].substring(0, tempBl[0].length()-cuttingLength) + tempBl[j];
					System.out.println(tempBl[0].substring(0, tempBl[0].length()-cuttingLength) + " : 자른후0번째 문자열");
					System.out.println(tempBl[j]+ " : 수정된 문자열");
					blNumList.add(tempBl[j]);
					blYearList.add(blYear[i]);
				}
			}
		} else { //구분문자가 없을때 그냥 추가
			blNumList.add(blNum[i]);
			blYearList.add(blYear[i]);
		}	
		
	}
	//디버깅
	for(int i = 0; i <blNumList.size(); i++ ) {
		System.out.println(blNumList.get(i).toUpperCase() +"<--검색 할"+(i+1)+"번째 bl번호");
		System.out.println(blYearList.get(i) +"<--검색 할 "+(i+1)+"번째 bl년도");
	}
	
	SimpleDateFormat transFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
	SimpleDateFormat lookupTimeFormat = new SimpleDateFormat ( "yyyy년 MM월dd일 HH시mm분ss초");
%>
	<section class = "section2">
	<form action="<%=request.getContextPath()%>/lookupResult.jsp" method = "post">
<%
	for(int i = 0; i < blNumList.size() ; i++ ) {
	%>
		
		<div id='my_div<%=i%>'>	
	<%
		String url = "https://unipass.customs.go.kr:38010/ext/rest/cargCsclPrgsInfoQry/retrieveCargCsclPrgsInfo?crkyCn=r200z280o057z221p040r040c0&hblNo="+blNumList.get(i).toUpperCase()+"&blYy="+blYearList.get(i);
		
		DocumentBuilderFactory dbFactory = DocumentBuilderFactory.newInstance();
		DocumentBuilder dBuilder = dbFactory.newDocumentBuilder();
		Document doc = dBuilder.parse(url);
		doc.getDocumentElement().normalize();
		System.out.println("Root element: " + doc.getDocumentElement().getNodeName()); // Root element: result
		
		
		// 파싱할 tag
		NodeList nList = doc.getElementsByTagName("cargCsclPrgsInfoQryRtnVo");
		System.out.println("파싱할 리스트 수 : "+ nList.getLength()); //1개밖에없음

		Node nNode = nList.item(0); //한개있는 노드를 가져옴
		Element eElement = (Element) nNode;
		/*
		
		조회되지않는 비엘일경우에 조회불가능 출력
		
		*/

		System.out.println("######################");
		CargoSummary summary = new CargoSummary();
		if(Search.getTagValue("tCnt", eElement).equals("0") || Search.getTagValue("tCnt", eElement).equals("-1")) {
		%>
			<table class = "table-bordered emptyTable prevTable">
				<tr>
					<th>
						<input type="text" value = "<%=blNumList.get(i).toUpperCase()%>" name = "blNum" readonly="readonly" size="30">
						<input type="hidden" value = "<%=blYearList.get(i)%>" name = "blYear">
					</th>
					<td>비엘번호가 잘못입력 되었거나, 유니패스에서 조회가 되지않습니다.</td>
				</tr>
			</table>
			<br>
			<div class = "center">
			<%
				Date time = new Date();
				String lookupTime = lookupTimeFormat.format(time);
			%>
				조회시간 : <%=lookupTime%>
			</div>
			<div class = "center">
				<input type='button' class="btn btn-secondary" value='조회결과삭제' onclick='deleteDiv(<%=i%>)'/>
			</div>
			<hr>
			</div>
		<%
			continue;
		}
		if(Search.getTagValue("ntceInfo", eElement) != null) {
		%>
			<table class = "table-bordered emptyTable prevTable">
				<tr>
					<th>
						<input type="text" value = "<%=blNumList.get(i).toUpperCase()%>" name = "blNum" readonly="readonly" size="30">
						<input type="hidden" value = "<%=blYearList.get(i)%>" name = "blYear">
					</th>
					<td>오류발생. 검색결과가 여러건일경우 정보를 제공하지않습니다. 유니패스에서 검색해주세요.(추후 추가예정)</td>
				</tr>
			</table>
			<br>
			<div class = "center">
			<%
				Date time = new Date();
				String lookupTime = lookupTimeFormat.format(time);
			%>
				조회시간 : <%=lookupTime%>
			</div>
			<div class = "center">
				<input type='button' class="btn btn-secondary" value='조회결과삭제' onclick='deleteDiv(<%=i%>)'/>
			</div>
			
			<hr>
			</div>
		<%
			System.out.println("오류발생");
			continue;
		}
		
		summary.cargMtNo = Search.getTagValue("cargMtNo", eElement);//화물관리번호
		summary.prgsStts = Search.getTagValue("prgsStts", eElement);//진행상태
		summary.shcoFlco = Search.getTagValue("shcoFlco", eElement);//선사/항공사
		summary.mblNo = Search.getTagValue("mblNo", eElement);//마스터비엘
		summary.hblNo = Search.getTagValue("hblNo", eElement);//하우스비엘
		summary.cargTp = Search.getTagValue("cargTp", eElement);//화물구분
		summary.shipNm = Search.getTagValue("shipNm", eElement);//항공편명
		summary.csclPrgsStts = Search.getTagValue("csclPrgsStts", eElement);//통관진행상태
		summary.prcsDttm = Search.getTagValue("prcsDttm", eElement);//처리일시 
		//처리일시 날짜 폼
		SimpleDateFormat prcsDttmFormat = new SimpleDateFormat("yyyyMMddHHmmss"); 
		SimpleDateFormat newPrcsDttmFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Date prcsDttmFormatDate = prcsDttmFormat.parse(summary.prcsDttm);
		String dateFormPrcsDttm = newPrcsDttmFormat.format(prcsDttmFormatDate);
		
		summary.prnm = Search.getTagValue("prnm", eElement);//품명
		summary.ldprNm = Search.getTagValue("ldprNm", eElement);//적재항
		summary.dsprNm = Search.getTagValue("dsprNm", eElement);//양륙항
		summary.etprCstm = Search.getTagValue("etprCstm", eElement);//입항세관
		summary.blPtNm = Search.getTagValue("blPtNm", eElement);//BL
		summary.etprDt = Search.getTagValue("etprDt", eElement);//입항일       
		//입할일 날짜 폼
		SimpleDateFormat etprDtFormat = new SimpleDateFormat("yyyyMMdd"); 
		SimpleDateFormat newEtprDtFormat= new SimpleDateFormat("yyyy-MM-dd");
		Date etprDtFormatDate = etprDtFormat.parse(summary.etprDt);
		String dateFormEtprDt = newEtprDtFormat.format(etprDtFormatDate);
		
		summary.mtTrgtCargYnNm = Search.getTagValue("mtTrgtCargYnNm", eElement);//관리대상 화물여부
		summary.rlseDtyPridPassTpcd = Search.getTagValue("rlseDtyPridPassTpcd", eElement);//반출의무과태로
		summary.dclrDelyAdtxYn = Search.getTagValue("dclrDelyAdtxYn", eElement);//신고지연가산세여부
		summary.spcnCargCd = Search.getTagValue("spcnCargCd", eElement);//특수화물코드
		if(summary.spcnCargCd == null) {
			summary.spcnCargCd = "";
		}
		summary.pckGcnt = Search.getTagValue("pckGcnt", eElement);//포장 갯수
		summary.pckUt = Search.getTagValue("pckUt", eElement);//포장단위
		summary.ttwg = Search.getTagValue("ttwg", eElement);//총중량
		summary.wghtUt = Search.getTagValue("wghtUt", eElement);//중량단위
		summary.tCnt = Integer.parseInt(Search.getTagValue("tCnt", eElement)) ;//응답레코드수 진행상황갯수
		summary.vydf = Search.getTagValue("vydf", eElement);//항차
		if(summary.vydf == null) {
			summary.vydf = "";
		}
		summary.lodCntyCd = Search.getTagValue("lodCntyCd", eElement);//적재항국가코드
		summary.frwrEntsConm = Search.getTagValue("frwrEntsConm", eElement);//포워더명
		if(summary.frwrEntsConm == null) {
			summary.frwrEntsConm = "";
		}
		summary.cntrNo = Search.getTagValue("cntrNo", eElement);//컨테이너번호
		if(summary.cntrNo == null) {
			summary.cntrNo = "";
		}
		
		System.out.println("응답레코드 수  : " + summary.tCnt);
		System.out.println("화물관리번호  : " + Search.getTagValue("cargMtNo", eElement));
		System.out.println("######################");
	%>
			<!-- 서머리 -->
			<div class = "summaryBlNum center">
				<h5><%=blNumList.get(i).toUpperCase()%></h5>
				<input type="hidden" value = "<%=blNumList.get(i).toUpperCase()%>" name = "blNum" >
				<input type="hidden" value = "<%=blYearList.get(i)%>" name = "blYear">
			</div>
					
			<table class = "table-bordered prevTable">
				<tr>
					<th class = "sumarryHeader">화물관리번호</th>
					<td><%=summary.cargMtNo%></td>
					<th class = "sumarryHeader">진행상태</th>
					<td><%=summary.prgsStts%></td>
					<th class = "sumarryHeader">선사/항공사</th>
					<td><%=summary.shcoFlco%></td>
					<th rowspan="8">
						<button type="button" class="btn btn-primary" data-toggle="collapse" data-target="#demo<%=i%>">상<br>세<br>진<br>행<br>정<br>보</button>	
					</th>
				</tr>
				<tr>
					<th class = "sumarryHeader">M B/L - H B/L</th>
					<td><%=summary.mblNo%> - <%=summary.hblNo%></td>
					<th class = "sumarryHeader">화물구분</th>
					<td><%=summary.cargTp%></td>
					<th class = "sumarryHeader">선박/항공편명</th>
					<td><%=summary.shipNm%></td>
				</tr>
				<tr>
					<th class = "sumarryHeader">통관진행상태</th>
					<td><%=summary.csclPrgsStts%></td>
					<th class = "sumarryHeader">처리일시</th>
					<td><%=dateFormPrcsDttm%></td>
					<th class = "sumarryHeader">적재항/적재국가</th>
					<td><%=summary.ldprNm%> / <%=summary.lodCntyCd%></td>
				</tr>
				<tr>
					<th class = "sumarryHeader">품명</th>
					<td colspan="5"><%=summary.prnm%></td>
				</tr>
				<tr>
					<th class = "sumarryHeader">포장개수</th>
					<td><%=summary.pckGcnt%> <%=summary.pckUt%></td>
					<th class = "sumarryHeader">총 중량</th>
					<td><%=summary.ttwg%> <%=summary.wghtUt%></td>
					<th class = "sumarryHeader">양륙항-항차</th>
					<td><%=summary.dsprNm%> - <%=summary.vydf%></td>
				</tr>
				<tr>
					<th class = "sumarryHeader">B/L유형</th>
					<td><%=summary.blPtNm%></td>
					<th class = "sumarryHeader">입항일</th>
					<td><%=dateFormEtprDt%></td>
					<th class = "sumarryHeader">입항세관</th>
					<td><%=summary.etprCstm%></td>
				</tr>
				<tr>
					<th class = "sumarryHeader">관리지정여부</th>
					<td><%=summary.mtTrgtCargYnNm%></td>
					<th class = "sumarryHeader">반출의무과태료</th>
					<td><%=summary.rlseDtyPridPassTpcd%></td>
					<th class = "sumarryHeader">신고지연가산세</th>
					<td><%=summary.dclrDelyAdtxYn%></td>		
				</tr>
				<tr>
					<th class = "sumarryHeader">특수화물코드</th>
					<td><%=summary.spcnCargCd%></td>
					<th class = "sumarryHeader">컨테이너번호</th>
					<td><%=summary.cntrNo%></td>
					<th class = "sumarryHeader">특송업체</th>
					<td><%=summary.frwrEntsConm%></td>		
				</tr>
			</table>
		
			<!-- 진행상황 -->
			<div   id="demo<%=i%>" class="collapse">
			<table class = "table-bordered prgsTable">
				
				<thead>
					
						<tr>
							<th rowspan="2">No</th>
							<th>처리단계</th>
							<th rowspan="2">장치장명</th>
							<th>포장개수</th>
							<th>반출입(처리)일시</th>
							<th rowspan="2">반출입근거번호</th>
						</tr>
						<tr>
							<th>처리일시</th>
							<th>중량</th>
							<th>반출입(처리)내용</th>
						</tr>

						
				</thead>
				<tbody>
		<%	
			
			// 진행상황 파싱 할 tag
			nList = doc.getElementsByTagName("cargCsclPrgsInfoDtlQryVo");
			System.out.println("진행상황 파싱할 리스트 수 : "+ nList.getLength());
			
			for(int j = 0; j <summary.tCnt; j++) {
				Node prgsNode = nList.item(j); //해당노드를 가져옴
				if(prgsNode.getNodeType() == Node.ELEMENT_NODE){
					Element prgsElement = (Element)prgsNode;
					Progress prgs = new Progress();
					
					prgs.cargTrcnRelaBsopTpcd = Search.getTagValue("cargTrcnRelaBsopTpcd", prgsElement);//처리단계
					if(prgs.cargTrcnRelaBsopTpcd == null) {
						prgs.cargTrcnRelaBsopTpcd = "";
					}
					prgs.pckUt = Search.getTagValue("pckUt", prgsElement);//포장갯수
					if(prgs.pckUt == null) {
						prgs.pckUt = "";
					}
					prgs.pckGcnt = Search.getTagValue("pckGcnt", prgsElement);//포장단위
					if(prgs.pckGcnt == null) {
						prgs.pckGcnt = "";
					}
					prgs.rlbrDttm = Search.getTagValue("rlbrDttm", prgsElement);//반출입(처리)일시
					if(prgs.rlbrDttm == null) {
						prgs.rlbrDttm = "";
					}
					prgs.prcsDttm = Search.getTagValue("prcsDttm", prgsElement);//발행일시  날짜폼
					if(prgs.prcsDttm == null) {
						prgs.prcsDttm = "";
					}
					//발행일시 날짜 폼
					SimpleDateFormat prgsPrcsDttmFormat = new SimpleDateFormat("yyyyMMddHHmmss"); 
					SimpleDateFormat newPrgsPrcsDttmFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
					Date prgsPrcsDttmFormatDate = prgsPrcsDttmFormat.parse(prgs.prcsDttm);
					String prgsPrcsDttmdateForm = newPrcsDttmFormat.format(prgsPrcsDttmFormatDate);
					
					prgs.shedNm = Search.getTagValue("shedNm", prgsElement);//장치장명
					if(prgs.shedNm == null) {
						prgs.shedNm = "";
					}
					prgs.wght = Search.getTagValue("wght", prgsElement);//중량
					if(prgs.wght == null) {
						prgs.wght = "";
					}
					prgs.wghtUt = Search.getTagValue("wghtUt", prgsElement);//중량단위
					if(prgs.wghtUt == null) {
						prgs.wghtUt = "";
					}
					prgs.rlbrCn = Search.getTagValue("rlbrCn", prgsElement);//반출입(처리)내용
					if(prgs.rlbrCn == null) {
						prgs.rlbrCn = "";
					}
					prgs.rlbrBssNo = Search.getTagValue("rlbrBssNo", prgsElement);//반출입근거번호
					if(prgs.rlbrBssNo == null) {
						prgs.rlbrBssNo = "";
					}
				
		%>					
						<colgroup span="2" class="hover"></colgroup>
						<tr>
							<td rowspan="2"><%=summary.tCnt - j%></td>
							<td><%=prgs.cargTrcnRelaBsopTpcd%></td>
							<td rowspan="2"><%=prgs.shedNm %></td>
							<td><%=prgs.pckGcnt%> <%=prgs.pckUt%></td>
							<td><%=prgs.rlbrDttm%></td>
							<td rowspan="2"><%=prgs.rlbrBssNo%></td>
						</tr>	
						<tr>
							<td rowspan=""><%=prgsPrcsDttmdateForm%></td>
							<td rowspan=""><%=prgs.wght%> <%=prgs.wghtUt %></td>
							<td rowspan=""><%=prgs.rlbrCn%></td>
						</tr>

						
				<%
				}
			}
			%>
				</tbody>
				</table>
			</div>
		<br>
		<div class = "center">
			<%
				Date time = new Date();
				String lookupTime = lookupTimeFormat.format(time);
			%>
				조회시간 : <%=lookupTime%>
			</div>
		<div  class = "center">
			<input type='button' class="btn btn-secondary" value='조회결과삭제' onclick='deleteDiv(<%=i%>)'/>
		</div>
		<hr>
		</div>
		<%	
	}
%>
		<table id="TblAttach" class = "table-bordered">
		</table>
		<br>
		<!-- 체크박스 전체선택 -->
		<div class = "center">
			<input type='checkbox' name='chkbox' value='selectall' onclick='selectAll(this)'/>전체선택
		</div>
		<br>
		<div class = "center">
			<input type='button' class="btn btn-info" value="선택 B/L삭제" onClick="delRow();"/>
			<input type='button' class="btn btn-info" value="B/L 추가" onClick="addRow();"/>
		</div>
		<br>

		<div class = "center">
			<button type = "submit" class="btn btn-info">다시조회</button>
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