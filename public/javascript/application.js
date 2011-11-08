(function() {
    $(function() {
        $("table#sortTable").tablesorter({
            sortList: [[0, 0]]
        });
        $("#reload").click(function(){
            $(this).attr("disabled", "disabled");
        });
        return $("a[rel^='prettyPopin']").prettyPopin({
            modal: true,
            width: 600,
            height: 260,
            opacity: 0.5,
            animationSpeed: '0',
            followScroll: true,
            loader_path: '/images/prettyPopin/loader.gif'
        });
    });
}).call(this);
