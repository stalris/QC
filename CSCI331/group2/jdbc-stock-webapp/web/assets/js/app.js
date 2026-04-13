(function () {
    const sidebar = document.getElementById('sidebar');
    const openSidebar = document.getElementById('openSidebar');
    const closeSidebar = document.getElementById('closeSidebar');

    function collapseSidebar() {
        if (sidebar) {
            sidebar.classList.add('collapsed');
        }
    }

    function expandSidebar() {
        if (sidebar) {
            sidebar.classList.remove('collapsed');
        }
    }

    if (window.innerWidth <= 900) {
        collapseSidebar();
    }

    if (openSidebar) {
        openSidebar.addEventListener('click', expandSidebar);
    }

    if (closeSidebar) {
        closeSidebar.addEventListener('click', collapseSidebar);
    }
})();
