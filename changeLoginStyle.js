var hideElements=new Array("footer","breadcrumbs","toptool","header");
for (var index in hideElements){
    document.getElementById(hideElements[index]).style.display="none";
}


var xpaths=new Array("//*[@id='main']/form/div/table/tbody/tr[6]", "//*[@id='main']/form/div/table/tbody/tr[7]",
                     "//*[@id='main']/form/div/table/tbody/tr[2]/th/input[2]","//*[@id='main']/form/div/table/tbody/tr[2]/td/a",
                     "//*[@id='main']/form/div/table/tbody/tr[3]/td/a","//*[@id='main']/form/div/table/tbody/tr[4]/td/font",
                     "//*[@id='main']/form/div/table/tbody/tr[5]/td/span");
for (var indexPath in xpaths){
    var yinshenNode =document.evaluate(xpaths[indexPath], document).iterateNext();
    yinshenNode.style.display="none";
}

var enmailTextNode =document.evaluate("//*[@id='main']/form/div/table/tbody/tr[2]/th", document).iterateNext();
enmailTextNode.innerHTML= "<input type=\"radio\" name=\"lgt\" value=\"0\" checked /> 用户名";
