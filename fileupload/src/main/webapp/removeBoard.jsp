<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "java.util.*" %>
<%@ page import = "java.sql.*" %>
<%
	if (request.getParameter("boardNo") == null){
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");
		return;
	}
	int boardNo = Integer.parseInt(request.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(request.getParameter("boardFileNo"));
	
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl= "jdbc:mariadb://127.0.0.1:3306/fileUpload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String sql = "SELECT b.board_no boardNo, b.board_title boardTitle, f.origin_filename originFilename, f.save_filename saveFilename, f.path path "
			+ "FROM board b INNER JOIN board_file f ON b.board_no = f.board_no ORDER BY b.createdate DESC";
	PreparedStatement stmt = conn.prepareStatement(sql);
	ResultSet rs = stmt.executeQuery();
	
	HashMap<String, Object> map = null;
	if(rs.next()) {
		map =  new HashMap<String, Object>();
		map.put("boardNo", rs.getInt("boardNo"));
		map.put("boardTitle", rs.getString("boardTitle"));
		map.put("originFilename", rs.getString("originFilename"));
		map.put("saveFilename", rs.getString("saveFilename"));
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<style type="text/css">
	table, th, td {
		border: 1px solid #FF0000;
	}
</style>
</head>
<body>
	<h1>board & boardFile 삭제</h1>
	<form action="<%=request.getContextPath()%>/removeBoardAction.jsp" method="post" enctype="multipart/form-data">
		<input type="hidden" name="boardNo" value="<%=map.get("boardNo")%>">
		<input type="hidden" name="saveFilename" value="<%=map.get("saveFilename")%>">
		<table>
			<tr>
				<th>boardTitle</th>
				<th>originFilename</th>
			</tr>
			<tr>
				<td><%=(String)map.get("boardTitle")%></td>
				<td>
					<%=(String)map.get("originFilename")%>
				</td>
			</tr>
		</table>
		<h4>
			정말 삭제하시겠습니까? <button type="submit">네</button>
		</h4>
	</form>
</body>
</html>