<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*" %>
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import = "vo.*" %>
<%@ page import = "java.io.*" %>
<%@ page import = "java.sql.*" %>
<%
	// upload 된 파일의 위치
	String dir = request.getServletContext().getRealPath("/upload");
	int max = 10 * 1024 * 1024;
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	System.out.println(mRequest.getOriginalFileName("boardFile") + " <- boardFile");

	if (mRequest.getParameter("boardNo") == null){
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");
		return;
	}
	// removeBoard.jsp 에서 saveFilename을 받아왔기때문에 sql로 받아오지 않아도 된다.
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	String saveFilename = mRequest.getParameter("saveFilename");
	
	
	// 1) file 삭제
	File f = new File(dir + "/" + saveFilename);
	if (f.exists()){
		f.delete();
		System.out.println(saveFilename + "파일삭제");
	}
	
	// 2) board 삭제
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl= "jdbc:mariadb://127.0.0.1:3306/fileUpload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	String boardSql = "DELETE FROM board WHERE board_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setInt(1, boardNo);
	int boardRow = boardStmt.executeUpdate();
	
	response.sendRedirect(request.getContextPath() + "/boardList.jsp");
%>