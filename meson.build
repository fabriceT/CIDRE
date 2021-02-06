project('cidre',
	'vala', 'c',
	version: '0.1')

dependencies = [
	dependency('glib-2.0'),
	dependency('gobject-2.0'),
	#dependency('gio-2.0'),
	#dependency('json-glib-1.0'),
]

add_project_arguments(
	'-DGETTEXT_PACKAGE="@0@"'.format(meson.project_name()),
	language: 'c'
)

#subdir('config')
subdir('src')
subdir('tests')


executable(
	meson.project_name(),
	source_files,
	#config_data,
	dependencies: dependencies,
	#include_directories: config_dir,
	install: true
)


test = executable('unit-test', sources: test1_sources, dependencies : dependencies)
test('unit-tests', test)

