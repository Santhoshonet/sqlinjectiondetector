$(function () {
    $('.button').click(function () {
        var res = $('input[type="text"]').validateText({});
        if(res)
            $('form').submit();
    });
    $('form').submit(function() {
        var res = $('input[type="text"]').validateText({});
        return res;
    });
    $('input[type="text"]').click(function() {
        if ($.trim($(this).val().toString().toLowerCase()) == "siteurl")
        {
            $(this).val('');
        }
    });
});