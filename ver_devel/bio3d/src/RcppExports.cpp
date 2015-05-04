// This file was generated by Rcpp::compileAttributes
// Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#include <Rcpp.h>

using namespace Rcpp;

// read_crd
List read_crd(std::string filename);
RcppExport SEXP bio3d_read_crd(SEXP filenameSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< std::string >::type filename(filenameSEXP);
    __result = Rcpp::wrap(read_crd(filename));
    return __result;
END_RCPP
}
// read_pdb
List read_pdb(std::string filename, bool multi, bool hex, int maxlines, bool atoms_only);
RcppExport SEXP bio3d_read_pdb(SEXP filenameSEXP, SEXP multiSEXP, SEXP hexSEXP, SEXP maxlinesSEXP, SEXP atoms_onlySEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< std::string >::type filename(filenameSEXP);
    Rcpp::traits::input_parameter< bool >::type multi(multiSEXP);
    Rcpp::traits::input_parameter< bool >::type hex(hexSEXP);
    Rcpp::traits::input_parameter< int >::type maxlines(maxlinesSEXP);
    Rcpp::traits::input_parameter< bool >::type atoms_only(atoms_onlySEXP);
    __result = Rcpp::wrap(read_pdb(filename, multi, hex, maxlines, atoms_only));
    return __result;
END_RCPP
}
// read_prmtop
List read_prmtop(std::string filename);
RcppExport SEXP bio3d_read_prmtop(SEXP filenameSEXP) {
BEGIN_RCPP
    Rcpp::RObject __result;
    Rcpp::RNGScope __rngScope;
    Rcpp::traits::input_parameter< std::string >::type filename(filenameSEXP);
    __result = Rcpp::wrap(read_prmtop(filename));
    return __result;
END_RCPP
}