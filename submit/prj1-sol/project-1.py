import re

class Token_struct:
    def __init__(self,kind,lexeme) -> None:
        self.kind= kind 
        self.lexeme=lexeme

def generate_token(string):
    regx=re.compile(r'(?:[{}[\]=,\.]|(?:\d+))')
    user_input=regx.findall(string)
    temp=[]
    for i in user_input:
        if i.isdecimal():
            temp.append(Token_struct('INT',i))
        else:
            temp.append(Token_struct(i,i))
    return temp

class Parser:
    def __init__(self,tokens):
        self.tokens=tokens
        self.index=0
        self.lookahead=self.next_token()

    def check(self, kind):
        return self.lookahead.kind == kind

    def match(self, kind):
        if self.check(kind):
            self.lookahead =  self.next_token()
        else:
            msg = 'expected{} got {} instead'.format(kind,self.lookahead.lexeme)
            print (msg)
            exit(1)
    
    
    def next_token(self):
        if self.index < len(self.tokens):
            temp= self.tokens[self.index]
            self.index+=1
            return temp
        else:
            return Token_struct("<EOF>","<EOF>")
    
    def full(self):
        if len(self.tokens)>0:
            return True
        else:
            return False


class RecursiveDecentParser(Parser):
    def __init__(self, tokens):
        super().__init__(tokens)
        self.results=[]
    
    

    #    initializersfunction
   
    def Func_initializerS(self):
        if (self.full()):
            x=[]
            temp = self.Func_initializer()
            x.append(temp)
            while(self.check(',')):
                self.match(',')
                if not (self.check('}')):
                    temp=self.Func_initializer()
                   
                    if type(temp) is list and temp[0] == 'a' and len(temp) == 3:
                        length_of_x = len(x)
                        start_of_index = temp[1]
                        if start_of_index > length_of_x:
                            difference = start_of_index - length_of_x + 1
                            zero = [0]*difference
                            x.extend(zero)
                            x[start_of_index] = temp[2]
                        else :
                            x[start_of_index]=temp[2]
                    elif type(temp) is list and temp[0] == 'a' and len(temp) == 4:
                        length_of_x = len(x)
                        start_of_index = temp[1]
                        end_of_index = temp[2]
                        if start_of_index > length_of_x:
                            difference = start_of_index - length_of_x + 1
                            zero =[0]*(difference-1)
                            value=[temp[3] for z in range(start_of_index,end_of_index)]
                            x.extend(zero)
                            x.extend(value)

                        elif end_of_index < length_of_x:
                            for k in range(start_of_index,end_of_index):
                                x[k]=temp[3]


                    else:
                        x.append(temp)
            return x

        pass

    
    #initializerfunction
    
    def Func_initializer(self):
         if (self.check('[')):
            self.match('[')
            index1= int(self.lookahead.lexeme)
            self.match('INT')
            if (self.check(']')):
                self.match(']')
                self.match('=')
                r=self.val()
                #bonky=self.update(ind1,t)
                bank=['a',index1,r]
                return bank

            elif(self.check('.')):
                self.match('.')
                self.match('.')
                self.match('.')
                index2= int(self.lookahead.lexeme)
                self.match('INT')
                self.match(']')
                self.match('=')
                s=self.val()
                #self.update(ind1,t,ind2)
                bank=['a',index1,index2,s]
                #self.result.extend(add)
                return bank
         else:
            s=self.val()
            #self.result.append(t)
            return s
    pass

   
    # function val
    
    def val(self):
        if (self.lookahead.kind == 'INT'):
            lexeme=int(self.lookahead.lexeme)
            self.match('INT')
            #self.result.append(lexeme)
            return  lexeme
        else:
            self.match( '{')
            t = self.Func_initializerS()
            self.match('}')
            return t

    pass

    def begin(self):
        xyz= self.Func_initializerS()
        print('\n')
        print(xyz)
        
     



if __name__ == '__main__':
    string_input="{{22, {44, 99}, [6...8]={33, 23,[3...8]={4,3}, 77}, 99}}"

    tokens = generate_token(string_input)
    abc=RecursiveDecentParser(tokens)
    abc.begin()
        





