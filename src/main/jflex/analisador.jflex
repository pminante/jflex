import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.Reader;
import java.nio.charset.Charset;

enum Classe {
    cId,
    cInt,
    cReal,
    cPalRes,
    cDoisPontos,
    cAtribuicao,
    cMais,
    cMenos,
    cDivisao,
    cMultiplicacao,
    cMaior,
    cMenor,
    cMaiorIgual,
    cMenorIgual,
    cDiferente,
    cIgual,
    cVirgula,
    cPontoVirgula,
    cPonto,
    cParEsq,
    cParDir,
    cString,
    cEOF,
}
class Value {
    private int valueInteger;
    private double valueDecimal;
    private String valueIdentification;

     public Value() {
    }

    public Value(double valueDecimal) {
        this.valueDecimal = valueDecimal;
    }

    public Value(int valueInteger) {
        this.valueInteger = valueInteger;
    }

    public Value(String valueIdentification) {
        this.valueIdentification = valueIdentification;
    }

    public int getValueInteger() {
        return valueInteger;
    }

    public void setValueInteger(int valueInteger) {
        this.valueInteger = valueInteger;
    }

    public double getValueDecimal() {
        return valueDecimal;
    }

    public void setValueDecimal(double valueDecimal) {
        this.valueDecimal = valueDecimal;
    }

    public String getValueIdentification() {
        return valueIdentification;
    }

    public void setValueIdentification(String valueIdentification) {
        this.valueIdentification = valueIdentification;
    }

    @Override
    public String toString() {
        return "Value { " +
                "valueInteger..: " + valueInteger +
                ", valueDecimal..: " + valueDecimal +
                ", valueIdentification..: '" + valueIdentification + '\'' +
                '}';
    }
}

class Token {
    private Classe classe;
    private Value value;
    private int line;
    private int column;

    public Token(int line, int column, Classe classe) {
            this.line = line;
            this.column = column;
            this.classe = classe;
    }

    public Token(int line, int column, Classe classe, Value value) {
          this.classe = classe;
          this.value = value;
          this.line = line;
          this.column = column;
    }

    public Classe getClasse() {
        return classe;
    }

    public void setClasse(Classe classe) {
        this.classe = classe;
    }

    public Value getValue() {
        return value;
    }

    public void setValue(Value value) {
        this.value = value;
    }

    public int getLine() {
        return line;
    }

    public void setLine(int line) {
        this.line = line;
    }

    public int getColumn() {
        return column;
    }

    public void setColumn(int column) {
        this.column = column;
    }

    @Override
    public String toString() {
        return "Token{" +
                "classe..: " + classe +
                ", value..: " + value +
                ", line..: " + line +
                ", column..: " + column +
                '}';
    }
}

%%

%class AnalisadorLexico
%type Token
%unicode
%column
%line


NUMERO = [0-9]
CARACTERE = [A-Za-z]
INTEIRO = {NUMERO}*
IDENTIFICADOR = {CARACTERE}({CARACTERE}|{NUMERO})*
STRING = \"[^\"]*\"

REAL = {INTEIRO}\.{NUMERO}+
PALAVRA_RESERVADA = "and"|"array"|"case"|"const"|"div"|"do"|"record"|"set"|"then"|"to"|"type"|"until"|"var"|"while"

OPERADOR = ":="|">="|"<="|"<>"|"="|":"|"\+"|"-"|"/"|"*"|">"|"<"|","|";"|"."
PARENTESE = "\(" | "\)"

FIMDELINHA = [\r\n]+
ESPACO = {FIMDELINHA} | [ \t\f]
%{
public static void main(String[] argv) {
        if (argv.length == 0) {
            System.out.println("dont have file");
        } else {
            int firstFilePos = 0;
            String encodingName = "UTF-8";
            if (argv[0].equals("--encoding")) {
                firstFilePos = 2;
                encodingName = argv[1];
                try {
                    Charset.forName(encodingName);
                } catch (Exception e) {
                    System.out.println("Invalid encoding '" + encodingName + "'");
                    return;
                }
            }
            for (int i = firstFilePos; i < argv.length; i++) {
                try {
                    processFile(argv[i], encodingName);
                } catch (FileNotFoundException e) {
                    System.out.println("File not found: \"" + argv[i] + "\"");
                } catch (IOException e) {
                    System.out.println("IO error scanning file \"" + argv[i] + "\"");
                    e.printStackTrace();
                } catch (Exception e) {
                    System.out.println("Unexpected exception:");
                    e.printStackTrace();
                }
            }
        }
    }

    private static void processFile(String filePath, String encodingName) throws IOException {
        try (FileInputStream stream = new FileInputStream(filePath);
             Reader reader = new InputStreamReader(stream, encodingName)) {
            AnalisadorLexico scanner = new AnalisadorLexico(reader);
            Token token;
            while (!scanner.zzAtEOF) {
                token = scanner.yylex();
                System.out.println(token);
            }
        }
    }
%}

%%

{ESPACO}     { /* Ignorar */ }

{INTEIRO}       { return new Token(yyline + 1, yycolumn + 1, Classe.cInt, new Value(Integer.parseInt(yytext()))); }
{PALAVRA_RESERVADA} { return new Token(yyline + 1, yycolumn + 1, Classe.cPalRes, new Value(yytext())); }
{IDENTIFICADOR} { return new Token(yyline + 1, yycolumn + 1, Classe.cId, new Value(yytext())); }
{STRING}        { return new Token(yyline + 1, yycolumn + 1, Classe.cString, new Value(yytext())); }
{REAL}          { return new Token(yyline + 1, yycolumn + 1, Classe.cReal, new Value(Double.parseDouble(yytext()))); }

{OPERADOR} {
    if(yytext() == ":"){
        return new Token(yyline + 1, yycolumn + 1, Classe.cDoisPontos, new Value(yytext()));
    }
    if(yytext() == ":="){
        return new Token(yyline + 1, yycolumn + 1, Classe.cAtribuicao, new Value(yytext()));
    }
    if(yytext() == "+"){
        return new Token(yyline + 1, yycolumn + 1, Classe.cMais, new Value(yytext()));
    }
    if(yytext() == "-"){
        return new Token(yyline + 1, yycolumn + 1, Classe.cMenos, new Value(yytext()));
    }
    if(yytext() == "/"){
        return new Token(yyline + 1, yycolumn + 1, Classe.cDivisao, new Value(yytext()));
    }
    if(yytext() == "*"){
        return new Token(yyline + 1, yycolumn + 1, Classe.cMultiplicacao, new Value(yytext()));
    }
    if(yytext() == ">"){
        return new Token(yyline + 1, yycolumn + 1, Classe.cMaior, new Value(yytext()));
    }
    if(yytext() == "<"){
        return new Token(yyline + 1, yycolumn + 1, Classe.cMenor, new Value(yytext()));
    }
    if(yytext() == ">="){
        return new Token(yyline + 1, yycolumn + 1, Classe.cMaiorIgual, new Value(yytext()));
    }
    if(yytext() == "<="){
        return new Token(yyline + 1, yycolumn + 1, Classe.cMenorIgual, new Value(yytext()));
    }
    if(yytext() == "<>"){
        return new Token(yyline + 1, yycolumn + 1, Classe.cDiferente, new Value(yytext()));
    }
    if(yytext() == "="){
        return new Token(yyline + 1, yycolumn + 1, Classe.cIgual, new Value(yytext()));
    }
    if(yytext() == ","){
        return new Token(yyline + 1, yycolumn + 1, Classe.cVirgula, new Value(yytext()));
    }
    if(yytext() == ";"){
        return new Token(yyline + 1, yycolumn + 1, Classe.cPontoVirgula, new Value(yytext()));
    }
    if(yytext() == "."){
        return new Token(yyline + 1, yycolumn + 1, Classe.cPonto, new Value(yytext()));
    }
}

{PARENTESE} {
    if(yytext() == "("){
        return new Token(yyline + 1, yycolumn + 1, Classe.cParEsq, new Value(yytext()));
    }
    if(yytext() == ")"){
        return new Token(yyline + 1, yycolumn + 1, Classe.cParDir, new Value(yytext()));
    }
}