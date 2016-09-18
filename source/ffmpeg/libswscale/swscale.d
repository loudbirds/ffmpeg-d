module ffmpeg.libswscale.swscale;
import std.stdint;
import ffmpeg.libavutil.avutil;

@nogc nothrow extern(C):

/**
* @defgroup libsws Color conversion and scaling
* @{
*
* Return the LIBSWSCALE_VERSION_INT constant.
*/
uint swscale_version();

/**
* Return the libswscale build-time configuration.
*/
char* swscale_configuration();

/**
* Return the libswscale license.
*/
char* swscale_license();

/* values for the flags, the stuff on the command line is different */
enum SWS_FAST_BILINEAR =   1;
enum SWS_BILINEAR      =    2;
enum SWS_BICUBIC     =      4;
enum SWS_X          =       8;
enum SWS_POINT      =    0x10;
enum SWS_AREA       =    0x20;
enum SWS_BICUBLIN   =    0x40;
enum SWS_GAUSS     =     0x80;
enum SWS_SINC      =    0x100;
enum SWS_LANCZOS  =     0x200;
enum SWS_SPLINE     =   0x400;

enum SWS_SRC_V_CHR_DROP_MASK  =   0x30000;
enum SWS_SRC_V_CHR_DROP_SHIFT  =  16;

enum SWS_PARAM_DEFAULT     =      123456;

enum SWS_PRINT_INFO         =     0x1000;

//the following 3 flags are not completely implemented
//internal chrominace subsampling info
enum SWS_FULL_CHR_H_INT  =  0x2000;
//input subsampling info
enum SWS_FULL_CHR_H_INP  =  0x4000;
enum SWS_DIRECT_BGR      =  0x8000;
enum SWS_ACCURATE_RND   =   0x40000;
enum SWS_BITEXACT        =  0x80000;
enum SWS_ERROR_DIFFUSION = 0x800000;

//#if FF_API_SWS_CPU_CAPS
/**
* CPU caps are autodetected now, those flags
* are only provided for API compatibility.
*/
enum SWS_CPU_CAPS_MMX  =    0x80000000;
enum SWS_CPU_CAPS_MMXEXT =  0x20000000;
enum SWS_CPU_CAPS_MMX2   =  0x20000000;
enum SWS_CPU_CAPS_3DNOW  =  0x40000000;
enum SWS_CPU_CAPS_ALTIVEC = 0x10000000;
//#if FF_API_ARCH_BFIN
enum SWS_CPU_CAPS_BFIN  =   0x01000000;
//#endif
enum SWS_CPU_CAPS_SSE2  =   0x02000000;
//#endif

enum SWS_MAX_REDUCE_CUTOFF = 0.002;

enum SWS_CS_ITU709   =      1;
enum SWS_CS_FCC       =     4;
enum SWS_CS_ITU601   =      5;
enum SWS_CS_ITU624     =    5;
enum SWS_CS_SMPTE170M  =    5;
enum SWS_CS_SMPTE240M  =    7;
enum SWS_CS_DEFAULT     =   5;

/**
* Return a pointer to yuv<->rgb coefficients for the given colorspace
* suitable for sws_setColorspaceDetails().
*
* @param colorspace One of the SWS_CS_* macros. If invalid,
* SWS_CS_DEFAULT is used.
*/
int *sws_getCoefficients(int colorspace);

// when used for filters they must have an odd number of elements
// coeffs cannot be shared between vectors
struct SwsVector {
    double *coeff;              ///< pointer to the list of coefficients
    int length;                 ///< number of coefficients in the vector
}

// vectors can be shared
struct SwsFilter {
    SwsVector *lumH;
    SwsVector *lumV;
    SwsVector *chrH;
    SwsVector *chrV;
}

struct SwsContext{}
/**
* Return a positive value if pix_fmt is a supported input format, 0
* otherwise.
*/
int sws_isSupportedInput(const AVPixelFormat pix_fmt);

/**
* Return a positive value if pix_fmt is a supported output format, 0
* otherwise.
*/
int sws_isSupportedOutput(const AVPixelFormat pix_fmt);

/**
* @param[in]  pix_fmt the pixel format
* @return a positive value if an endianness conversion for pix_fmt is
* supported, 0 otherwise.
*/
int sws_isSupportedEndiannessConversion(const AVPixelFormat pix_fmt);

/**
* Allocate an empty SwsContext. This must be filled and passed to
* sws_init_context(). For filling see AVOptions, options.c and
* sws_setColorspaceDetails().
*/
SwsContext *sws_alloc_context();

/**
* Initialize the swscaler context sws_context.
*
* @return zero or positive value on success, a negative value on
* error
*/
int sws_init_context( SwsContext *sws_context, SwsFilter *srcFilter, SwsFilter *dstFilter);

/**
* Free the swscaler context swsContext.
* If swsContext is NULL, then does nothing.
*/
void sws_freeContext( SwsContext *swsContext);

/**
* Allocate and return an SwsContext. You need it to perform
* scaling/conversion operations using sws_scale().
*
* @param srcW the width of the source image
* @param srcH the height of the source image
* @param srcFormat the source image format
* @param dstW the width of the destination image
* @param dstH the height of the destination image
* @param dstFormat the destination image format
* @param flags specify which algorithm and options to use for rescaling
* @return a pointer to an allocated context, or NULL in case of error
* @note this function is to be removed after a saner alternative is
*       written
*/
SwsContext *sws_getContext(int srcW, int srcH, const AVPixelFormat srcFormat,
                                  int dstW, int dstH, const AVPixelFormat dstFormat,
                                  int flags, SwsFilter *srcFilter,
                                  SwsFilter *dstFilter, const double *param);

/**
* Scale the image slice in srcSlice and put the resulting scaled
* slice in the image in dst. A slice is a sequence of consecutive
* rows in an image.
*
* Slices have to be provided in sequential order, either in
* top-bottom or bottom-top order. If slices are provided in
* non-sequential order the behavior of the function is undefined.
*
* @param c         the scaling context previously created with
*                  sws_getContext()
* @param srcSlice  the array containing the pointers to the planes of
*                  the source slice
* @param srcStride the array containing the strides for each plane of
*                  the source image
* @param srcSliceY the position in the source image of the slice to
*                  process, that is the number (counted starting from
*                  zero) in the image of the first row of the slice
* @param srcSliceH the height of the source slice, that is the number
*                  of rows in the slice
* @param dst       the array containing the pointers to the planes of
*                  the destination image
* @param dstStride the array containing the strides for each plane of
*                  the destination image
* @return          the height of the output slice
*/
int sws_scale(SwsContext *c, const uint8_t **srcSlice,
              const int *srcStride, int srcSliceY, int srcSliceH,
              const uint8_t **dst, const int *dstStride);

/**
* @param dstRange flag indicating the while-black range of the output (1=jpeg / 0=mpeg)
* @param srcRange flag indicating the while-black range of the input (1=jpeg / 0=mpeg)
* @param table the yuv2rgb coefficients describing the output yuv space, normally ff_yuv2rgb_coeffs[x]
* @param inv_table the yuv2rgb coefficients describing the input yuv space, normally ff_yuv2rgb_coeffs[x]
* @param brightness 16.16 fixed point brightness correction
* @param contrast 16.16 fixed point contrast correction
* @param saturation 16.16 fixed point saturation correction
* @return -1 if not supported
*/
int sws_setColorspaceDetails( SwsContext *c, const int [4]inv_table,
                             int srcRange, const int [4]table, int dstRange,
                             int brightness, int contrast, int saturation);

/**
* @return -1 if not supported
*/
int sws_getColorspaceDetails( SwsContext *c, int **inv_table,
                             int *srcRange, int **table, int *dstRange,
                             int *brightness, int *contrast, int *saturation);

/**
* Allocate and return an uninitialized vector with length coefficients.
*/
SwsVector *sws_allocVec(int length);

/**
* Return a normalized Gaussian curve used to filter stuff
* quality = 3 is high quality, lower is lower quality.
*/
SwsVector *sws_getGaussianVec(double variance, double quality);

/**
* Allocate and return a vector with length coefficients, all
* with the same value c.
*/
SwsVector *sws_getConstVec(double c, int length);

/**
* Allocate and return a vector with just one coefficient, with
* value 1.0.
*/
SwsVector *sws_getIdentityVec();

/**
* Scale all the coefficients of a by the scalar value.
*/
void sws_scaleVec(SwsVector *a, double scalar);

/**
* Scale all the coefficients of a so that their sum equals height.
*/
void sws_normalizeVec(SwsVector *a, double height);
void sws_convVec(SwsVector *a, SwsVector *b);
void sws_addVec(SwsVector *a, SwsVector *b);
void sws_subVec(SwsVector *a, SwsVector *b);
void sws_shiftVec(SwsVector *a, int shift);

/**
* Allocate and return a clone of the vector a, that is a vector
* with the same coefficients as a.
*/
SwsVector *sws_cloneVec(SwsVector *a);

/**
* Print with av_log() a textual representation of the vector a
* if log_level <= av_log_level.
*/
void sws_printVec2(SwsVector *a, AVClass *log_ctx, int log_level);

void sws_freeVec(SwsVector *a);

SwsFilter *sws_getDefaultFilter(float lumaGBlur, float chromaGBlur,
                                float lumaSharpen, float chromaSharpen,
                                float chromaHShift, float chromaVShift,
                                int verbose);
void sws_freeFilter(SwsFilter *filter);

/**
* Check if context can be reused, otherwise reallocate a new one.
*
* If context is NULL, just calls sws_getContext() to get a new
* context. Otherwise, checks if the parameters are the ones already
* saved in context. If that is the case, returns the current
* context. Otherwise, frees context and gets a new context with
* the new parameters.
*
* Be warned that srcFilter and dstFilter are not checked, they
* are assumed to remain the same.
*/
 SwsContext *sws_getCachedContext( SwsContext *context,
                                        int srcW, int srcH, const AVPixelFormat srcFormat,
                                        int dstW, int dstH, const AVPixelFormat dstFormat,
                                        int flags, SwsFilter *srcFilter,
                                        SwsFilter *dstFilter, const double *param);

/**
* Convert an 8-bit paletted frame into a frame with a color depth of 32 bits.
*
* The output frame will have the same packed format as the palette.
*
* @param src        source frame buffer
* @param dst        destination frame buffer
* @param num_pixels number of pixels to convert
* @param palette    array with [256] entries, which must match color arrangement (RGB or BGR) of src
*/
void sws_convertPalette8ToPacked32(const uint8_t *src, uint8_t *dst, int num_pixels, const uint8_t *palette);

/**
* Convert an 8-bit paletted frame into a frame with a color depth of 24 bits.
*
* With the palette format "ABCD", the destination frame ends up with the format "ABC".
*
* @param src        source frame buffer
* @param dst        destination frame buffer
* @param num_pixels number of pixels to convert
* @param palette    array with [256] entries, which must match color arrangement (RGB or BGR) of src
*/
void sws_convertPalette8ToPacked24(const uint8_t *src, uint8_t *dst, int num_pixels, const uint8_t *palette);

/**
* Get the AVClass for swsContext. It can be used in combination with
* AV_OPT_SEARCH_FAKE_OBJ for examining options.
*
* @see av_opt_find().
*/
AVClass *sws_get_class();

/**
* @}
*/
