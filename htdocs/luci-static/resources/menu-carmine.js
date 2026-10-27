'use strict';
'require baseclass';
'require ui';

/*
 * Carmine - a clean, modern theme for LuCI
 * Licensed to the public under the Apache License 2.0.
 *
 * Renders the sidebar navigation, the page tabs, the breadcrumb
 * in the top bar and wires up the mobile drawer and light/dark toggle.
 */

function clearOpen(except) {
	var open = document.querySelectorAll('#mainmenu .nav-section.open');

	for (var i = 0; i < open.length; i++) {
		if (open[i] !== except) {
			open[i].classList.remove('open');
			open[i].firstElementChild.setAttribute('aria-expanded', 'false');
		}
	}
}

return baseclass.extend({
	__init__: function() {
		this.bindChrome();
		ui.menu.load().then(L.bind(this.render, this));
	},

	render: function(tree) {
		var path = L.env.dispatchpath || [],
		    node = tree,
		    url = '',
		    mode = this.renderModeMenu(tree);

		if (mode)
			this.renderMainMenu(mode, mode.name);

		if (path.length >= 3) {
			for (var i = 0; i < 3 && node; i++) {
				node = (node.children || {})[path[i]];
				url = url + (url ? '/' : '') + path[i];
			}

			if (node)
				this.renderTabMenu(node, url, 0);
		}

		this.renderCrumbs(mode);
		this.revealActive();
	},

	renderModeMenu: function(tree) {
		var ul = document.querySelector('#modemenu'),
		    children = ui.menu.getChildren(tree),
		    reqpath = L.env.requestpath || [],
		    active = null;

		children.forEach(function(child, index) {
			var isActive = reqpath.length ? (child.name === reqpath[0]) : (index === 0);

			if (ul)
				ul.appendChild(E('li', { 'class': isActive ? 'active' : null }, [
					E('a', { 'href': L.url(child.name) }, [ _(child.title) ])
				]));

			if (isActive)
				active = child;
		});

		if (ul && children.length > 1)
			ul.style.display = '';

		return active;
	},

	renderMainMenu: function(tree, url) {
		var container = document.querySelector('#mainmenu'),
		    ul = E('ul', { 'class': 'nav' }),
		    children = ui.menu.getChildren(tree),
		    path = L.env.dispatchpath || [];

		if (!container)
			return;

		children.forEach(function(child) {
			if (child.name == 'logout') {
				this.renderLogout(child, url);
				return;
			}

			var subs = ui.menu.getChildren(child),
			    isActive = (path[1] == child.name),
			    li = E('li', {
			    	'class': 'nav-section' + (isActive ? ' active open' : ''),
			    	'data-menu': child.name
			    });

			if (subs.length) {
				var sub = E('ul', { 'class': 'nav-sub' });

				subs.forEach(function(s) {
					var subActive = isActive && (path[2] == s.name);

					sub.appendChild(E('li', { 'class': subActive ? 'active' : null, 'data-menu': s.name }, [
						E('a', {
							'href': L.url(url, child.name, s.name),
							'aria-current': subActive ? 'page' : null
						}, [ _(s.title) ])
					]));
				});

				li.appendChild(E('a', {
					'href': '#',
					'class': 'nav-head',
					'role': 'button',
					'aria-expanded': isActive ? 'true' : 'false',
					'click': ui.createHandlerFn(this, 'handleSectionToggle')
				}, [
					E('span', { 'class': 'nav-icon', 'aria-hidden': 'true' }),
					E('span', { 'class': 'nav-label' }, [ _(child.title) ]),
					E('span', { 'class': 'nav-caret', 'aria-hidden': 'true' })
				]));

				li.appendChild(sub);
			}
			else {
				li.appendChild(E('a', {
					'href': L.url(url, child.name),
					'class': 'nav-head',
					'aria-current': isActive ? 'page' : null
				}, [
					E('span', { 'class': 'nav-icon', 'aria-hidden': 'true' }),
					E('span', { 'class': 'nav-label' }, [ _(child.title) ])
				]));
			}

			ul.appendChild(li);
		}, this);

		container.appendChild(ul);
		container.style.display = '';
	},

	renderTabMenu: function(tree, url, level) {
		var container = document.querySelector('#tabmenu'),
		    ul = E('ul', { 'class': 'tabs' }),
		    children = ui.menu.getChildren(tree),
		    path = L.env.dispatchpath || [],
		    activeNode = null;

		if (!container || !children.length)
			return;

		children.forEach(function(child) {
			var isActive = (path[3 + level] == child.name);

			ul.appendChild(E('li', { 'class': 'tabmenu-item-%s%s'.format(child.name, isActive ? ' active' : '') }, [
				E('a', { 'href': L.url(url, child.name) }, [ _(child.title) ])
			]));

			if (isActive)
				activeNode = child;
		});

		container.appendChild(ul);
		container.style.display = '';

		if (activeNode)
			this.renderTabMenu(activeNode, url + '/' + activeNode.name, level + 1);
	},

	renderLogout: function(node, url) {
		var slot = document.querySelector('#logout-slot');

		if (!slot)
			return;

		slot.appendChild(E('a', {
			'class': 'logout-btn',
			'href': L.url(url, node.name),
			'title': _(node.title)
		}, [
			E('span', { 'class': 'i i-logout', 'aria-hidden': 'true' }),
			E('span', { 'class': 'logout-text' }, [ _(node.title) ])
		]));
	},

	renderCrumbs: function(mode) {
		var crumbs = document.querySelector('#crumbs'),
		    path = L.env.dispatchpath || [],
		    titles = [],
		    node = mode;

		if (!crumbs || !mode)
			return;

		for (var i = 1; i < path.length && node; i++) {
			node = (node.children || {})[path[i]];

			if (node && node.title)
				titles.push(_(node.title));
		}

		titles = titles.slice(0, 2);

		titles.forEach(function(title, i) {
			if (i > 0)
				crumbs.appendChild(E('span', { 'class': 'crumb-sep', 'aria-hidden': 'true' }));

			crumbs.appendChild(E(i == titles.length - 1 ? 'strong' : 'span',
				{ 'class': 'crumb' + (i == titles.length - 1 ? ' current' : '') }, [ title ]));
		});
	},

	revealActive: function() {
		var sidebar = document.querySelector('#sidebar'),
		    link = document.querySelector('#mainmenu .nav-sub li.active > a');

		if (sidebar && link) {
			var top = link.getBoundingClientRect().top - sidebar.getBoundingClientRect().top;

			if (top > sidebar.clientHeight - 80)
				sidebar.scrollTop = top - sidebar.clientHeight / 2;
		}
	},

	handleSectionToggle: function(ev) {
		var head = ev.currentTarget,
		    li = head.parentNode,
		    open = !li.classList.contains('open');

		ev.preventDefault();

		clearOpen(li);

		if (open)
			li.classList.add('open');
		else
			li.classList.remove('open');

		head.setAttribute('aria-expanded', open ? 'true' : 'false');
		head.blur();
	},

	bindChrome: function() {
		var body = document.body,
		    toggle = document.querySelector('#menu-toggle'),
		    scrim = document.querySelector('#scrim'),
		    mode = document.querySelector('#mode-toggle'),
		    mq = window.matchMedia ? window.matchMedia('(min-width: 1025px)') : null;

		var setOpen = function(open) {
			if (open)
				body.classList.add('nav-open');
			else
				body.classList.remove('nav-open');

			if (toggle)
				toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
		};

		if (toggle)
			toggle.addEventListener('click', function() {
				setOpen(!body.classList.contains('nav-open'));
			});

		if (scrim)
			scrim.addEventListener('click', function() { setOpen(false) });

		document.addEventListener('keydown', function(ev) {
			if (ev.key == 'Escape' && body.classList.contains('nav-open') &&
			    !body.classList.contains('modal-overlay-active'))
				setOpen(false);
		});

		if (mq) {
			var onChange = function() { if (mq.matches) setOpen(false) };

			if (mq.addEventListener)
				mq.addEventListener('change', onChange);
			else if (mq.addListener)
				mq.addListener(onChange);
		}

		if (mode)
			mode.addEventListener('click', function() {
				var dark = document.documentElement.getAttribute('data-darkmode') == 'true',
				    want = dark ? 'light' : 'dark',
				    sys = (window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches) ? 'dark' : 'light';

				/* picking the system's own mode drops the override, so the
				 * page follows the device setting again */
				if (typeof(window.carmineSetMode) == 'function')
					window.carmineSetMode(want == sys ? null : want);

				mode.blur();
			});
	}
});
