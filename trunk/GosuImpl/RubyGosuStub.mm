#include <Gosu/Directories.hpp>
#include <Gosu/Utility.hpp>
#include <unistd.h>
#include "ruby.h"
#include "oniguruma.h"

extern "C" void Init_gosu();
extern "C" void Init_syck();
extern "C" void Init_socket();
extern "C" void Init_stringio();

extern "C" int rb_enc_register(const char *, OnigEncodingType*);
extern "C" void rb_encdb_declare(const char *name);
extern OnigEncodingType OnigEncodingASCII;
extern OnigEncodingType OnigEncodingUS_ASCII;
extern OnigEncodingType OnigEncodingUTF_8;
extern OnigEncodingType OnigEncodingUTF_16BE;
extern OnigEncodingType OnigEncodingUTF_16LE;
extern OnigEncodingType OnigEncodingUTF_32BE;
extern OnigEncodingType OnigEncodingUTF_32LE;

int main()
{
    std::string resourcePath = Gosu::wstringToUTF8(Gosu::resourcePrefix());
    chdir(resourcePath.c_str());

    std::string mainPath = resourcePath + "gosu/run.rb";

    char* argv[] = { "ruby", const_cast<char*>(mainPath.c_str()), 0 };
    int argc = 2;
    
    char** argvPointer = argv;
    ruby_sysinit(&argc, &argvPointer);
    { 
        RUBY_INIT_STACK; 

        ruby_init();

        rb_encdb_declare(OnigEncodingASCII.name);
        rb_encdb_declare(OnigEncodingUS_ASCII.name);
        rb_encdb_declare(OnigEncodingUTF_8.name);
        rb_enc_register(OnigEncodingUTF_16BE.name, &OnigEncodingUTF_16BE);
        rb_enc_register(OnigEncodingUTF_16LE.name, &OnigEncodingUTF_16LE);
        rb_enc_register(OnigEncodingUTF_32BE.name, &OnigEncodingUTF_32BE);
        rb_enc_register(OnigEncodingUTF_32LE.name, &OnigEncodingUTF_32LE);

        Init_gosu();
        Init_syck();
        Init_socket();
        Init_stringio();
        rb_eval_string("$LOADED_FEATURES << 'gosu.bundle'");
        rb_eval_string("$LOADED_FEATURES << 'rubygems.rb'");
        rb_eval_string("$LOADED_FEATURES << 'syck.bundle'");
        rb_eval_string("$LOADED_FEATURES << 'socket.bundle'");
        rb_eval_string("$LOADED_FEATURES << 'stringio.bundle'");

        return ruby_run_node(ruby_options(argc, argv)); 
    }
}
