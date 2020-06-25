import pyodbc as SQL
import pandas as pd
import os

cnxn = SQL.connect("Driver={SQL Server Native Client 11.0};"
    "Server=DESKTOP-092RK20\SQLEXPRESS;"
    "Database=BDSpotPer_FINAL;"
    "Trusted_Connection=yes;")

# CONSULTAS

consulta_albuns = "select * from album"
consulta_playlists = "select cod, nome, dt_criacao, dt_ult_reprod, num_reprod from playlist"
consulta_faixas_album = "select numero, f.descr, tempo, nome as composicao, tipo_grav from faixa f, composicao c where tipo_composicao = cod and cod_album = "
consulta_faixas_playlist = "select numero, descr, tempo, composicao, tipo_grav from faixas_playlists where cod_playlist = "
consulta_faixas_playlist_cods = "select * from faixas_playlists where cod_playlist = "

consulta_item_a = "select * from oitoa order by 2 desc"
consulta_item_b = "select * from oitob"
consulta_item_c = "select * from oitoc"
consulta_item_d = "select * from oitod"

# PRINTS MENUS

print_menu = '\n ---------------MENU---------------\n [1] Albuns\n [2] Playlists\n [3] Questão 8\n [0] Sair'
print_menu1_1 = '\n---------------MENU---------------\n [1] Faixas do Album\n [0] Sair'
print_menu1_2 = '\n---------------MENU---------------\n [1] Adicionar Faixa a Playlist\n [0] Sair'
print_menu2_1 = '\n ---------------MENU---------------\n [1] Faixas da Playlist\n [2] Tocar Playlist\n [3] Editar Playlist\n [4] Criar Playlist\n [5] Apagar Playlist\n [0] Sair'
print_menu2_2 = '\n ---------------MENU---------------\n [1] Tocar faixa\n [2] Adicionar Faixa\n [3] Apagar Faixa\n [0] Sair'
print_menu3_1 = '\n ---------------MENU---------------\n [1] Item A\n [2] Item B\n [3] Item C\n [4] Item D\n [0] Sair'

print_albuns = '\n---------------------------------------------ALBUNS---------------------------------------------'
print_faixas = '\n-----------------------------FAIXAS-----------------------------'
print_playlists = '\n-----------------------PLAYLISTS-------------------------'

#CODIGO

menu = True
while(menu):   
     

    #MENU
    os.system("cls")
    print(print_menu)
    menu = input("\n [ ] ")

    if(menu == "1"):
    
        menu_album = True
        while(menu_album):
    
            #ALBUNS E MENU1_1
            os.system("cls")
            print(print_albuns)
            tabela = pd.read_sql(consulta_albuns,cnxn)
            print(tabela)
            print(print_menu1_1)
            menu_album = input("\n [ ] ")
    
            if(menu_album == "1"):

                try:    
                    #dados
                    comando=int( input("\n Selecione a Linha do Album: ") ) 
                    cod_album = tabela['cod'][comando]
                    faixas = pd.read_sql(consulta_faixas_album+str(cod_album),cnxn)

                    menu_faixa = True
                    while(menu_faixa):

                        #FAIXAS E MENU1_2            
                        os.system("cls")
                        print(print_faixas)
                        print(faixas)
                        print(print_menu1_2)
                        menu_faixa = input("\n [ ] ")

                        if(menu_faixa == "1"):

                            #ADICIONAR FAIXA A ALBUM
                            try:

                                #dados
                                comando=int( input("\n Selecione a Linha da Faixa: ") )
                                numero_faixa = faixas['numero'][comando]
                            
                                #print playlist
                                playlists = pd.read_sql(consulta_playlists,cnxn)
                                os.system("cls")
                                print(print_playlists)
                                print(playlists)
                                print('\n')

                                #dados
                                comando=int( input("\n Selecione a Linha da Playlist: ") )
                                cod_playlist = playlists['cod'][comando]
                                                        
                                #executando operacao
                                cursor=cnxn.cursor()
                                cursor.execute("INSERT INTO faixa_playlist VALUES ("+str(numero_faixa)+","+str(cod_album)+","+str(cod_playlist)+")")
                                cnxn.commit()
                                cursor.close()

                            
                            except:
                                input("\n Operação Inválida, prescione enter para continuar")
                        


                        elif(menu_faixa == "0"):
                            menu_faixa = False

                except:
                    input("\n Operação Inválida, prescione enter para continuar")
            


            elif(menu_album == '0'):
            	menu_album = False   

    elif(menu == "2"):
    
        menu_playlist = True
        while(menu_playlist):
            
            os.system("cls")
            print(print_playlists)
            tabela = pd.read_sql(consulta_playlists,cnxn)
            print(tabela)
            print(print_menu2_1)
            menu_playlist = input("\n [ ] ")

            if(menu_playlist == "1"):

                try:    

                    comando=int( input("\n Selecione a Linha da Playlist: ") ) 
                    cod_playlist = tabela['cod'][comando]
      
                    menu_faixa = True
                    while(menu_faixa): 
       
                        
                        os.system("cls")
                        faixas = pd.read_sql(consulta_faixas_playlist+str(cod_playlist),cnxn)
                        print(print_faixas)
                        print(faixas)

                        print(print_menu2_2)
                        menu_faixa = input("\n [ ] ")

                        if(menu_faixa == "1"):
                            
                            try:

                                input("\n Selecione a Linha da Faixa: ")
                                num_reprod = tabela['num_reprod'][comando]
                                num_reprod = int(num_reprod) + 1

                                cursor=cnxn.cursor()
                                cursor.execute("UPDATE playlist SET dt_ult_reprod = GETDATE(), num_reprod = "+ str(num_reprod) + "WHERE cod="+str(cod_playlist))
                                cnxn.commit()
                                cursor.close()
                        
                            except:
                                input("\n Operação Inválida, prescione enter para continuar")
                        




                        elif(menu_faixa == "2"):

                            try:
                        
                                os.system("cls")
                                print(print_albuns)
                                tabela = pd.read_sql(consulta_albuns,cnxn)
                                print(tabela)

                                comando=int( input("\n Selecione a Linha do Album: ") )

                                os.system("cls")
                                print(print_faixas)
                                cod_album = tabela['cod'][comando]
                                faixas = pd.read_sql(consulta_faixas_album+str(cod_album),cnxn)
                                print(faixas)

                                comando=int( input("\n Selecione a Linha da Faixa: ") )
                                numero_faixa = faixas['numero'][comando]
                                                            
                                #executando operacao
                                cursor=cnxn.cursor()
                                cursor.execute("INSERT INTO faixa_playlist VALUES ("+str(numero_faixa)+","+str(cod_album)+","+str(cod_playlist)+")")
                                cnxn.commit()
                                cursor.close()

                            except:
                                input("\n Operação Inválida, prescione enter para continuar")
                        


                        elif(menu_faixa == "3"):

                            try:
                                
                                comando=int( input("\n Selecione a Linha da Faixa: ") )
                                faixas = pd.read_sql(consulta_faixas_playlist_cods+str(cod_playlist),cnxn)
                                numero = faixas['numero'][comando]
                                cod_album = faixas['cod_album'][comando]
                                                    
                                cursor = cnxn.cursor()
                                cursor.execute("DELETE FROM faixa_playlist WHERE numero_faixa ="+ str(numero) +"and cod_album = "+ str(cod_album) +"and cod_playlist = " + str(cod_playlist))
                                cnxn.commit()
                                cursor.close()

                            except:
                                input("\n Operação Inválida, prescione enter para continuar")
                        

                        elif(menu_faixa == "0"):
                            menu_faixa = False

                except:
                    input("\n Operação Inválida, prescione enter para continuar")
            

            elif(menu_playlist == "2"):

                try:

                    comando=int( input("\n Selecione a Linha da Playlist: ") )
                    cod_playlist = tabela['cod'][comando]
                    num_reprod = tabela['num_reprod'][comando]
                    num_reprod = int(num_reprod) + 1

                    cursor=cnxn.cursor()
                    cursor.execute("UPDATE playlist SET dt_ult_reprod = GETDATE(), num_reprod = "+ str(num_reprod) + "WHERE cod="+str(cod_playlist))
                    cnxn.commit()
                    cursor.close()
                    
                except:
                    input("\n Operação Inválida, prescione enter para continuar")


            elif(menu_playlist == "3"):
                
                try:
                    comando=int( input("\n Selecione a Linha da Playlist: ") ) 
                    cod_playlist = tabela['cod'][comando]
                    nome = input("\n Nome: ")

                    cursor=cnxn.cursor()
                    cursor.execute("UPDATE playlist SET nome="+"'"+nome+"'"+" WHERE cod="+str(cod_playlist))
                    cnxn.commit()
                    cursor.close()
                
                except:
                    input("\n Operação Inválida, prescione enter para continuar")
            

            #SELECIONAR PLAYLIST

            elif(menu_playlist == "4"):
                
                try:
                    cod = input("\n Qual o codigo da playlist?: ")
                    nome = input("\n Qual o nome dela? ")
                    
                    cursor = cnxn.cursor()
                    cursor.execute("INSERT INTO playlist VALUES ("+ cod +",'"+ nome +"',GETDATE(),GETDATE(),0,'00:00:00')")
                    cnxn.commit()
                    cursor.close()

                except:
                    input("\n Operação Inválida, prescione enter para continuar")
            

    
            elif(menu_playlist == "5"):

                try:
                    comando=int( input("\n Selecione a Linha da Playlist: ") ) 
                    cod_playlist = tabela['cod'][comando]

                    cursor = cnxn.cursor()
                    cursor.execute("DELETE FROM playlist WHERE cod="+str(cod_playlist))
                    cnxn.commit()
                    cursor.close()

                except:
                    input("\n Operação Inválida, prescione enter para continuar")


            elif(menu_playlist == "0"):
    	        menu_playlist = False


    elif(menu == "3"):

        menu_itens = True
        while(menu_itens):

            os.system("cls")
            print(print_menu3_1)
            menu_itens = input("\n [ ] ")


            if (menu_itens == "1"):
                try:

                    os.system("cls")
                    print("------------ITEM A------------")
                    tabela = pd.read_sql(consulta_item_a,cnxn)
                    print(tabela)

                    input("\n Prescione enter para voltar")

                except:
                    input("\n Operação Inválida, prescione enter para continuar")

            elif (menu_itens == "2"):
                try:
                    os.system("cls")
                    print("------------ITEM B------------")
                    tabela = pd.read_sql(consulta_item_b,cnxn)
                    print(tabela)

                    input("\n Prescione enter para voltar")

                except:
                    input("\n Operação Inválida, prescione enter para continuar")

            elif (menu_itens == "3"):
                try:
                    
                    os.system("cls")
                    print("------------ITEM C------------")
                    tabela = pd.read_sql(consulta_item_c,cnxn)
                    print(tabela)

                    input("\n Prescione enter para voltar")

                except:
                    input("\n Operação Inválida, prescione enter para continuar")

            elif (menu_itens == "4"):
                try:

                    os.system("cls")
                    print("------------ITEM D------------")
                    tabela = pd.read_sql(consulta_item_d,cnxn)
                    print(tabela)

                    input("\n Prescione enter para voltar")

                except:
                    input("\n Operação Inválida, prescione enter para continuar")

            elif (menu_itens == "0"):
                menu_itens = False

    elif(menu == "0"):
        os.system("cls")
        menu = False