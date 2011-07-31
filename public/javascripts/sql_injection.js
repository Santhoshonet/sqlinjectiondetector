$(function() {
    // start your stuff here
    var is_site_created = false;
    $('input[type="button"]').click(function() {
        if(!is_site_created) {
            create_site();
        }
        return false;
    });
    $('form').submit(function(){
        if(!is_site_created) {
            create_site();
        }
        return false;            
    });
    function create_site()
    {
        if($.trim($('input[type="text"').val()) != "")
         {
             $.ajax({
                url: "/sites/create",
                async: true,
                cache: false,
                type: 'GET',
                data: {'site': {'url': $('input[type="text"').val() } },
                contentType: 'application/json; charset=utf-8',
                dataType: 'html/text/xml/json',
                beforeSend: function() {

                },
                success: function (data) {
                    var d = $.parseJSON(data);
                    if(d.status == "success")
                    {
                        start_sql_injection(d.id,1);
                        $('input[type="button"]').hide();
                        is_site_created = true;
                    }
                    else
                    {
                        alert(d.status);
                    }
                },
                error: function (e) {
                    alert(e);
                }
            });
          }
         else
         {
             $('input[type="text"').focus();
         }
        return false;
    }

    function start_sql_injection(site_id,index)
    {
        var li = jQuery("<li>",{});
        li.append("started");
        $('.sql_injection_results').append(li);
        $.ajax({
            url: "/sql_injection/index",
            cache: false,
            timeout: 99999,
            type: 'GET',
            data: {'siteid': site_id, 'iterationid' : index },
            contentType: 'application/json; charset=utf-8',
            dataType: 'html/text/xml/json',
            beforeSend: function() {
            },
            success: function (data) {
                var d = $.parseJSON(data);
                if(d.status == "success")
                {
                    start_sql_injection(site_id,index+1);
                }
                else
                {
                    alert(d.status);
                }
            },
            error: function (e) {
            }
        });
        return false;
    }
});