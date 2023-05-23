<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.*" %><!-- cos.jar -->
<%@ page import="com.oreilly.servlet.multipart.*" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "vo.*" %>
<%@ page import = "java.io.*" %> <!-- 폴더 안에 불필요한 파일을 삭제하기 위함 -->
<%
	// 이 프로젝트 내 upload폴더의 실제 물리적 위치를 반환
	String dir = request.getServletContext().getRealPath("/upload");
	int max = 10 * 1024 * 1024;
	
	// request객체를 MultipartRequest의 API를 사용할 수 있도록 랩핑 
	// new MultipartRequest(원본request, 업로드폴더, 최대파일사이즈byte, 인코딩, 중복이름정책)
	// DefaultFileRenamePolicy() 파일 중복이름 방지
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	System.out.println(mRequest.getOriginalFileName("boardFile") + " <- boardFile");

	
	/* 요청값 유효성 검사 */
	if(mRequest.getParameter("boardNo") == null) {
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");
		return;
	}
	// removeBoard.jsp 에서 boardNo 및 saveFilename을 "hidden"으로 받아옴 → DB에서 sql쿼리로 받아오지 않아도 된다!
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	String saveFilename = mRequest.getParameter("saveFilename");
	
	
	// 1) file 삭제
	File f = new File(dir + "/" + saveFilename);
	if (f.exists()){
		f.delete();
		System.out.println(saveFilename + " 파일삭제");
	}
	
	/* DB 연결 */
	String driver = "org.mariadb.jdbc.Driver";
	String dbUrl= "jdbc:mariadb://127.0.0.1:3306/fileUpload";
	String dbUser = "root";
	String dbPw = "java1234";
	Class.forName(driver);
	Connection conn = DriverManager.getConnection(dbUrl, dbUser, dbPw);
	
	// 2) board 삭제
	String boardSql = "DELETE FROM board WHERE board_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setInt(1, boardNo);
	int boardRow = boardStmt.executeUpdate();
	
	if(boardRow == 0) {
		System.out.println("board 삭제 실패");
	} else {
		System.out.println("board 삭제 성공");
		response.sendRedirect(request.getContextPath() + "/boardList.jsp");
	}
%>