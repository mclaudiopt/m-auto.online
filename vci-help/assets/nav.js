/* ALLScanner Wiki — Sidebar Navigation */
(function () {
  'use strict';

  document.addEventListener('DOMContentLoaded', function () {
    // --- Collapsible sections ---
    var headers = document.querySelectorAll('.nav-section-header');
    headers.forEach(function (header) {
      var section = header.parentElement;
      var items = section.querySelector('.nav-items');
      if (!items) return;

      // Set initial max-height so animation works
      items.style.maxHeight = items.scrollHeight + 'px';

      header.addEventListener('click', function () {
        section.classList.toggle('collapsed');
        if (section.classList.contains('collapsed')) {
          items.style.maxHeight = '0';
        } else {
          items.style.maxHeight = items.scrollHeight + 'px';
        }
      });
    });

    // --- Mark active link ---
    var currentPath = window.location.pathname;
    var links = document.querySelectorAll('.nav-link');
    links.forEach(function (link) {
      if (link.getAttribute('href') === currentPath ||
          currentPath.endsWith(link.getAttribute('href'))) {
        link.classList.add('active');
        // Ensure parent section is expanded
        var section = link.closest('.nav-section');
        if (section && section.classList.contains('collapsed')) {
          section.classList.remove('collapsed');
          var items = section.querySelector('.nav-items');
          if (items) items.style.maxHeight = items.scrollHeight + 'px';
        }
      }
    });

    // --- Mobile hamburger ---
    var hamburger = document.getElementById('hamburger');
    var sidebar = document.getElementById('sidebar');
    var overlay = document.getElementById('overlay');

    if (hamburger && sidebar) {
      hamburger.addEventListener('click', function () {
        sidebar.classList.toggle('open');
        if (overlay) overlay.classList.toggle('active');
      });
    }

    if (overlay) {
      overlay.addEventListener('click', function () {
        if (sidebar) sidebar.classList.remove('open');
        overlay.classList.remove('active');
      });
    }
  });
})();
