<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title></title>
    <script type='text/javascript'>
        document.addEventListener('DOMContentLoaded',submitForm);
        function submitForm() {
                document.getElementById("form").submit();
        };
    </script>
</head>
<body>
<form id='form' method='POST' action="<%=request.getAttribute("url")%>">
    <input type='hidden' name='data' value='<%=request.getAttribute("data")%>' />
</form>
Your request is being forwarded.... If you have JavaScript disabled please click <a href='#' onclick='submitForm(); return false;'>Here</a>
</body>
</html>