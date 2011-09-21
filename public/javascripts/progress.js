$(function() {
    //setTimeout(counter(),1000);
    counter();
    function counter()
    {
        // ajax requesting here to find out the status
        $.ajax({
            url: "/sql_injection/sql_injection_status/" + $('#siteID').html() ,
            async: true,
            cache: false,
            type: 'GET',
            data: {},
            contentType: 'text/html; charset=utf-8',
            dataType: 'text/html',
            beforeSend: function() {
            },
            success: function(data) {
                modifyProgress(data);
            },
            error: function(e) {
                if(e.status == 200)
                {
                    modifyProgress(e.responseText);
                }
            }
        });
    }
    function modifyProgress(data)
    {
        try
        {
            var val = parseInt(data);
            if($.trim($('#status_total').html()) == $.trim(data))
            {
                window.location = "/sql_injection/analysis/" + $('#siteID').html();
                return;
            }
            else
                $('#status_count').html(val);
        }catch(e){}
        setTimeout(counter,5000);
    }
});