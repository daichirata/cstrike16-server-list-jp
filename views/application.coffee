$ ->
    $("table#sortTable").tablesorter
        sortList: [[0,0]]

    $("a[rel^='prettyPopin']").prettyPopin
        modal: true
        width: 600
        height: 260
        opacity: 0.5
        animationSpeed: '0'
        followScroll: true
        loader_path: '/images/prettyPopin/loader.gif'
