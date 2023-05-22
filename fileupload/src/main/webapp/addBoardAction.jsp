<%@ page import="javax.print.attribute.standard.PresentationDirection"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import = "com.oreilly.servlet.MultipartRequest"%>
<%@ page import = "com.oreilly.servlet.multipart.DefaultFileRenamePolicy"%>
<%@ page import = "vo.*"%>
<%@ page import = "java.io.*"%>
<%@ page import = "java.sql.*" %>
<%
	// 프로젝트안 upload폴더의 실제 물리적 위치를 반환
	String dir = request.getServletContext().getRealPath("/upload");
	System.out.println(dir + " <-- dir");
	
	int max = 10 * 1024 * 1024;
	// request객체를 MultipartRequest의 API를 사용할 수 있도록 랩핑 
	// new MultipartRequest(원본request, 업로드폴더, 최대파일사이즈byte, 인코딩, 중복이름정책)
	
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	
	// MultipartRequest API를 사용하여 스트림내에서 문자값을 반환받을 수 있다
	
	// 업로드 파일이 PDF 파일이 아니면
	if(mRequest.getContentType("boardFile").equals("application/pdf") == false) {
		// 이미 저장된 파일을 삭제
		System.out.println("PDF파일이 아닙니다");
		String saveFilename = mRequest.getFilesystemName("boardFile");
		File f = new File(dir+"\\"+saveFilename); // 지우는 파일은 풀네임을 적어야함 new File("d/abc/upload화면캡쳐.gif")
		if(f.exists()) {
			f.delete();
			System.out.println(dir+"\\"+saveFilename+"파일삭제");
		}
		response.sendRedirect(request.getContextPath()+"/addBoard.jsp");
		return;
	}
	
	// 1) input type="text" 값 반환 API	--> board 테이블 저장
	String boardTitle = mRequest.getParameter("boardTitle");
	String memberId = mRequest.getParameter("memberId");
	
	System.out.println(boardTitle + " <-- boardTitle");
	System.out.println(memberId + " <-- memberId");
	
	Board board = new Board();
	board.setBoardTitle(boardTitle);
	board.setMemberId(memberId);
	
	// 2) input type="file" 값 (파일 메타 정보)반환 API(원본파일이름, 저장된파일이름, 컨텐츠타입)		--> board_file테이블 저장			
	// 파일(바이너리)은 이미 MultipartRequest 객체 생성시 (request 랩핑시, 9라인) 먼저 저장
	String type = mRequest.getContentType("boardFile");
	String originFilename = mRequest.getOriginalFileName("boardFile");
	String saveFilename = mRequest.getFilesystemName("boardFile");
	
	System.out.println(type + " <-- type");
	System.out.println(originFilename + " <-- originFilename");
	System.out.println(saveFilename + " <-- saveFilename");
	
	BoardFile boardFile = new BoardFile();
	// boardFile.setBoardNo(boardNo);
	boardFile.setType(type);
	boardFile.setOriginFilename(originFilename);
	boardFile.setSaveFilename(saveFilename);
	
	/*
		INSERT INTO board(board_title, membe_id, updatedate, createdate)
		VALUES(?, ?, NOW(), NOW());
		
		INSERT INTO board_file(board_no, origin_filename, save_filename, path, type, createdate)
		VALUES(?, ?, ?, ?, ?, NOW());
		
		INSERT쿼리 실행 후 기본키값 받아오기 JDBC API
		String sql = "INSERT 쿼리문";
		pstmt = con.prepareStatement(sql, PreparedStatement.RETURN_GENERATED_KEYS);
		int row = pstmt.executeUpdate(); // insert 쿼리 실행
		ResultSet keyRs = pstmt.getGeneratedKeys(); // insert 후 입력된 행의 키값을 받아오는 select쿼리를 진행
		int keyValue = 0;
		if(keyRs.next()){
			keyValue = rs.getInt(1);
		}
	*/
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");
	String boardSql = "INSERT INTO board(board_title, member_id, updatedate, createdate) VALUES(?, ?, NOW(), NOW())";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql, PreparedStatement.RETURN_GENERATED_KEYS); 	// insert하면서 들어간 키값을 받을 수 있다?
	boardStmt.setString(1, boardTitle);
	boardStmt.setString(2, memberId);
	
	int boardRow = boardStmt.executeUpdate(); 	// 저장된 키값을 반환
	ResultSet keyRs = boardStmt.getGeneratedKeys();
	int boardNo = 0;
	if(keyRs.next()) {
		boardNo = keyRs.getInt(1);
	}
	
	String fileSql = "INSERT INTO board_file(board_no, origin_filename, save_filename, type, path, createdate) VALUES(?, ?, ?, ?, 'upload', NOW())";
	PreparedStatement fileStmt = conn.prepareStatement(fileSql);
	fileStmt.setInt(1, boardNo);
	fileStmt.setString(2, originFilename);
	fileStmt.setString(3, saveFilename);
	fileStmt.setString(4, type); 
	fileStmt.executeQuery(); 	// board_file 입력
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");
	
%>