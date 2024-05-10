message(STATUS "'internal' dependencies mode selected for Jinja2Cpp. All dependencies will be built from source pulled from github")

include (./thirdparty/internal_deps.cmake)

set(BOOST_ENABLE_CMAKE ON)
list(APPEND BOOST_INCLUDE_LIBRARIES
    algorithm
    assert
    atomic
    filesystem
    lexical_cast
    optional
    variant
    json
    regex
)

include(FetchContent)
FetchContent_Declare(
    Boost
    URL https://github.com/boostorg/boost/releases/download/boost-1.83.0/boost-1.83.0.tar.gz
    URL_HASH SHA256=0c6049764e80aa32754acd7d4f179fd5551d8172a83b71532ae093e7384e98da
    PATCH_COMMAND git apply --ignore-whitespace "${CMAKE_CURRENT_LIST_DIR}/../cmake/patches/0001-fix-skip-install-rules.patch" || true
)
FetchContent_MakeAvailable(Boost)

if(NOT MSVC)
    # Enable -Werror and -Wall on jinja2cpp target, ignoring warning errors from thirdparty libs
    include(CheckCXXCompilerFlag)
    check_cxx_compiler_flag(-Wno-error=parentheses COMPILER_HAS_WNO_ERROR_PARENTHESES_FLAG)
    check_cxx_compiler_flag(-Wno-error=deprecated-declarations COMPILER_HAS_WNO_ERROR_DEPRECATED_DECLARATIONS_FLAG)
    check_cxx_compiler_flag(-Wno-error=maybe-uninitialized COMPILER_HAS_WNO_ERROR_MAYBE_UNINITIALIZED_FLAG)

    if(COMPILER_HAS_WNO_ERROR_PARENTHESES_FLAG)
        target_compile_options(boost_assert INTERFACE -Wno-error=parentheses)
    endif()
    if(COMPILER_HAS_WNO_ERROR_DEPRECATED_DECLARATIONS_FLAG)
        target_compile_options(boost_unordered INTERFACE -Wno-error=deprecated-declarations)
        target_compile_options(boost_filesystem PRIVATE -Wno-error=deprecated-declarations)
    endif()
    if(COMPILER_HAS_WNO_ERROR_MAYBE_UNINITIALIZED_FLAG)
        target_compile_options(boost_variant INTERFACE -Wno-error=maybe-uninitialized)
    endif()
        else ()
endif()

# install(TARGETS boost_filesystem boost_algorithm boost_variant boost_optional
#        EXPORT InstallTargets
#        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
#        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
#        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/static
#        PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/boost
#        )
