vcpkg_check_linkage(ONLY_STATIC_LIBRARY)

vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO swift-nav/nanopb
    REF 4161d73ba0c3ecd10170ac0d3e9a34cbb88a8061
    SHA512 3ffb5b0223f4b875da44e61e4c2d13751d1f94bc28dd24913cdbac450fd4d04cb2a7a972d26170552977a02173daaaab56abf2e78a8509da8a83aba4c0386eda
    HEAD_REF cmake-fix
)

string(COMPARE EQUAL "${VCPKG_LIBRARY_LINKAGE}" "static" nanopb_BUILD_STATIC_LIBS)
string(COMPARE EQUAL "${VCPKG_CRT_LINKAGE}" "static" nanopb_STATIC_LINKING)


vcpkg_check_features(OUT_FEATURE_OPTIONS FEATURE_OPTIONS
    FEATURES
        generator nanopb_BUILD_GENERATOR
)

vcpkg_find_acquire_program(PYTHON3)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    PREFER_NINJA
    OPTIONS
        -DPython_EXECUTABLE=${PYTHON3}
        -Dnanopb_BUILD_RUNTIME=ON
        -DBUILD_STATIC_LIBS=${nanopb_BUILD_STATIC_LIBS}
        -Dnanopb_MSVC_STATIC_RUNTIME=${nanopb_STATIC_LINKING}
        -Dnanopb_PROTOC_PATH=${CURRENT_HOST_INSTALLED_DIR}/tools/protobuf/protoc${VCPKG_HOST_EXECUTABLE_SUFFIX}
        ${FEATURE_OPTIONS}
)
vcpkg_install_cmake()

vcpkg_copy_pdbs()

vcpkg_fixup_cmake_targets(CONFIG_PATH lib/cmake/${PORT})

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

if(nanopb_BUILD_GENERATOR)
    file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/nanopb_generator.py" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    if(WIN32)
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/protoc-gen-nanopb.bat" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
        file(INSTALL "${CURRENT_PACKAGES_DIR}/Lib/site-packages/" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}/site-packages")
    else()
        file(INSTALL "${CURRENT_PACKAGES_DIR}/bin/protoc-gen-nanopb" DESTINATION "${CURRENT_PACKAGES_DIR}/tools/${PORT}")
    endif()
endif()

if(nanopb_BUILD_STATIC_LIBS)
    file(REMOVE_RECURSE "${CURRENT_PACKAGES_DIR}/bin" "${CURRENT_PACKAGES_DIR}/debug/bin")
endif()
# Handle copyright
configure_file(${SOURCE_PATH}/LICENSE.txt ${CURRENT_PACKAGES_DIR}/share/${PORT}/copyright COPYONLY)
