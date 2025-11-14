# 서일 북스토어 (Seoil BookStore)

Spring MVC로 구현된 온라인 서점 예제 애플리케이션입니다. 도서 검색/추천, 장바구니와 주문, 회원 관리, 관리자 대시보드 등 전형적인 커머스 흐름을 학습하거나 확장하는 데 초점을 맞추고 있습니다.

## 프로젝트 개요
- **아키텍처**: Spring MVC + JSP + MyBatis 기반의 전통적인 WAR 배포 구조
- **데이터베이스**: Oracle XE (HikariCP 커넥션 풀 사용)
- **빌드 산출물**: `shopping-0.0.1-SNAPSHOT.war`
- **배포 대상**: Apache Tomcat 9+ 또는 호환 서블릿 컨테이너

## 주요 기능
### 사용자 영역
- 도서 목록/검색, 상세/리뷰, 베스트셀러, 추천 도서 조회 (`BookController`)
- 장바구니 담기·수량 조정·삭제, 즉시 구매/일괄 결제 (`CartController`, `OrderController`)
- 회원 가입/로그인, 정보 수정, 주문 내역 조회 (`MemberController`, `OrderController`)
- FAQ·정적 페이지 및 JSP 기반 UI (`src/main/webapp/WEB-INF/views/user/*`)

### 관리자 영역
- 도서 CRUD, 이미지 업로드, 판매/리뷰 통계 시각화 (`AdminController`)
- 회원 검색·가입 통계, 주문 현황 관리 (`AdminController`, `MemberService`, `OrderService`)
- 리뷰 모니터링 및 삭제, 재고·판매량 업데이트

## 기술 스택
- **Backend**: Spring Context/Web MVC 5.3, Spring JDBC, MyBatis 3.5, MyBatis-Spring 2.0
- **Database**: Oracle JDBC (ojdbc8) + HikariCP 5.0
- **View**: JSP, JSTL, Servlet API 4.0, Logback/SLF4J 로깅
- **Build**: Maven 3.8+, Java 8, WAR Packaging
- **기타**: Lombok, Commons FileUpload/IO, Jackson Databind

## 필수 사전 준비
1. **JDK 8** 이상 (프로젝트 `maven.compiler.source/target=1.8`)
2. **Apache Maven 3.8+**
3. **Oracle XE** 또는 호환 DB, 예시 연결 정보는 `src/main/resources/config/hikari.properties`
4. **Tomcat 9+** (WAR 배포용)

## 빠른 시작
1. 저장소 복제
   ```powershell
   git clone <repo-url>
   cd SeoilBookStore
   ```
2. 데이터베이스 연결 정보 수정: `src/main/resources/config/hikari.properties`
3. Oracle DB에 테이블/시드 데이터를 생성 (DDL은 프로젝트 요구사항에 맞게 별도 작성)
4. Maven 의존성 설치 및 빌드
   ```powershell
   mvn clean package
   ```
5. 생성된 `target/shopping-0.0.1-SNAPSHOT.war`를 Tomcat `webapps/`에 배포 후 서버 기동

## 주요 폴더 구조
```
src/
  main/
    java/
      controller/   ← MVC Controller (회원, 도서, 주문, 장바구니, FAQ, 관리자)
      service/      ← 비즈니스 로직/트랜잭션 래핑 계층
      mapper/       ← MyBatis Mapper 인터페이스
      model/        ← DTO/엔터티 (Book, Member, Order, Review 등)
    resources/
      config/       ← `hikari.properties`, `mybatis-config.xml`
    webapp/
      WEB-INF/
        views/      ← JSP 뷰 (user/admin)
        dispatcher-servlet.xml, applicationContext.xml
pom.xml
```

## 환경 구성
- `src/main/webapp/WEB-INF/applicationContext.xml`: Spring 빈 정의, DataSource/MyBatis 스캔 설정
- `src/main/webapp/WEB-INF/dispatcher-servlet.xml`: HandlerMapping, ViewResolver 등 MVC 설정
- `src/main/resources/config/mybatis-config.xml`: Alias, Mapper 위치 설정
- DB 접속 정보는 OS 환경 변수 대신 `hikari.properties`에서 관리하므로 배포 환경별 복사본을 유지하세요.

## 빌드 & 배포
- 표준 빌드: `mvn clean package`
- 테스트 스킵: `mvn clean package -DskipTests`
- WAR 배포 후 `http://localhost:8080/SeoilBookStore/books` (컨텍스트 루트는 Tomcat 설정에 따름)
- 개발 중 JSP/Hikari 설정이 바뀌면 Tomcat 재시작 또는 `touch`로 리로드

## 개발 워크플로
1. 변경 사항을 커밋하기 전 `mvn -q test`로 빠르게 컴파일/매퍼 검증을 수행합니다.
2. 기능이 정상이라면 `mvn clean package`로 WAR를 생성합니다.
3. 새로 생성된 `target/shopping-0.0.1-SNAPSHOT.war`를 로컬 또는 스테이징 Tomcat에 배포해 UI를 확인합니다.
4. 데이터베이스 스키마나 설정이 바뀌면 `src/main/resources/config`와 `WEB-INF` 설정 파일을 함께 점검합니다.

## 테스트
- 현재 별도 단위/통합 테스트 코드가 포함돼 있지 않습니다.
- 신규 기능 추가 시 JUnit + Spring TestContext 기반의 테스트 모듈을 추가하는 것을 권장합니다.

## 향후 개선 아이디어
- 스키마/데이터 초기화를 위한 SQL 스크립트와 Docker Compose 제공
- Spring Security 도입으로 세션 기반 인증·권한 강화
- 주문/결제 화면을 REST API + 프론트엔드 SPA로 분리
- CI 파이프라인에서 정적 분석(SpotBugs, Checkstyle) 및 테스트 자동화
