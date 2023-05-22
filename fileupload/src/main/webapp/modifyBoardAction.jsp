<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import = "java.sql.*" %>
<%@ page import = "java.io.*"%>
<%@ page import = "vo.*" %>
<%
	String dir = request.getServletContext().getRealPath("/upload");
	int max = 10 * 1024 * 1024;
	MultipartRequest mRequest = new MultipartRequest(request, dir, max, "utf-8", new DefaultFileRenamePolicy());
	System.out.println(mRequest.getOriginalFileName("boardFile") + " <--boardFile");
	// mRequest.getOriginalFileName("boardFile") 값이 null이면 board테이블에 title만 수정
	
	int boardNo = Integer.parseInt(mRequest.getParameter("boardNo"));
	int boardFileNo = Integer.parseInt(mRequest.getParameter("boardFileNo"));
	
	
	// 1) board_title 수정
	String boardTitle = mRequest.getParameter("boardTitle");
	
	Class.forName("org.mariadb.jdbc.Driver");
	Connection conn = DriverManager.getConnection("jdbc:mariadb://127.0.0.1:3306/fileupload","root","java1234");
	String boardSql = "UPDATE board SET board_title = ? WHERE board_no = ?";
	PreparedStatement boardStmt = conn.prepareStatement(boardSql);
	boardStmt.setString(1, boardTitle);
	boardStmt.setInt(2, boardNo);
	int boardRow = boardStmt.executeUpdate();
	
	// 2) 이전 boardFile 삭제, 새로운 boardFile 추가 테이블을 수정
	if(mRequest.getOriginalFileName("boardFile") != null) {
	
		// 수정할 파일이 있으면,
		// PDF 파일 유효성 검사
		if(mRequest.getContentType("boardFile").equals("application/pdf") == false) {
			System.out.println("PDF파일이 아닙니다");
			String saveFilename = mRequest.getFilesystemName("boardFile");
			// 아니면 새로 업로드 한 파일을 삭제
			File f = new File(dir + "/" + saveFilename); 
			if(f.exists()) {
				f.delete();
				System.out.println(saveFilename + "파일삭제");
			}
		} else { 
		// PDF파일이면,  
		// 1) 이전 파일(saveFilename) 삭제
		// 2) db수정(update)
		String type = mRequest.getContentType("boardFile");
		String originFilename = mRequest.getOriginalFileName("boardFile");
		String saveFilename = mRequest.getFilesystemName("boardFile");
		
		BoardFile boardFile = new BoardFile();
		boardFile.setBoardFileNo(boardFileNo);
		boardFile.setType(type);
		boardFile.setOriginFilename(originFilename);
		boardFile.setSaveFilename(saveFilename);
		
		// 1) 이전파일 삭제
		String saveFilenameSql = "SELECT save_filename FROM board_file WHERE board_file_no=?";
		PreparedStatement saveFilenameStmt = conn.prepareStatement(saveFilenameSql);
		saveFilenameStmt.setInt(1, boardFile.getBoardFileNo());
		ResultSet saveFilenameRs = saveFilenameStmt.executeQuery();
		String preSaveFilename = "";
		if(saveFilenameRs.next()) {
			preSaveFilename = saveFilenameRs.getString("save_filename");
		}
		File f = new File(dir + "/" + preSaveFilename);
		if(f.exists()) {
			f.delete();
		}
		// 2) 수정된 파일의 정보로 db를 수정
		/*
			UPDATE board_file 
			SET origin_filename=?, save_filename=? 
			WHERE board_file_no=?
		*/
		String boardFileSql = "UPDATE board_file SET origin_filename=?, save_filename=? WHERE board_file_no=?";
		PreparedStatement boardFileStmt = conn.prepareStatement(boardFileSql);
		boardFileStmt.setString(1, boardFile.getOriginFilename());
		boardFileStmt.setString(2, boardFile.getSaveFilename());
		boardFileStmt.setInt(3, boardFile.getBoardFileNo());
		int boardFileRow = boardFileStmt.executeUpdate();
		}
	}
	
	response.sendRedirect(request.getContextPath()+"/boardList.jsp");	
%>