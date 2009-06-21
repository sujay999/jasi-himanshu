package jasi;
public class Constants {

    //token type constants
    public final static int TOKEN_TYPE_CHAR = 0;
    public final static int TOKEN_TYPE_NUMBER = TOKEN_TYPE_CHAR + 1;
    public final static int TOKEN_TYPE_STRING = TOKEN_TYPE_NUMBER + 1;
    public final static int TOKEN_TYPE_BOOLEAN = TOKEN_TYPE_STRING + 1;
    public final static int TOKEN_TYPE_LPAREN = TOKEN_TYPE_BOOLEAN + 1;
    public final static int TOKEN_TYPE_RPAREN = TOKEN_TYPE_LPAREN + 1;
    public final static int TOKEN_TYPE_VARIABLE = TOKEN_TYPE_RPAREN + 1;
}
