      SUBROUTINE XPOMAX(MO,MALINI,MAILX,NBNOC,NBMAC,PREFNO,NOGRFI,
     &                  MAXFEM,CNS1,CNS2,CES1,CES2,CESVI1,CESVI2,
     &                  LISTGR,DIRGRM,NIVGRM,RESUCO)

C            CONFIGURATION MANAGEMENT OF EDF VERSION
C MODIF PREPOST  DATE 27/07/2009   AUTEUR NISTOR I.NISTOR 
C ======================================================================
C COPYRIGHT (C) 1991 - 2007  EDF R&D                  WWW.CODE-ASTER.ORG
C THIS PROGRAM IS FREE SOFTWARE; YOU CAN REDISTRIBUTE IT AND/OR MODIFY  
C IT UNDER THE TERMS OF THE GNU GENERAL PUBLIC LICENSE AS PUBLISHED BY  
C THE FREE SOFTWARE FOUNDATION; EITHER VERSION 2 OF THE LICENSE, OR     
C (AT YOUR OPTION) ANY LATER VERSION.                                   
C                                                                       
C THIS PROGRAM IS DISTRIBUTED IN THE HOPE THAT IT WILL BE USEFUL, BUT   
C WITHOUT ANY WARRANTY; WITHOUT EVEN THE IMPLIED WARRANTY OF            
C MERCHANTABILITY OR FITNESS FOR A PARTICULAR PURPOSE. SEE THE GNU      
C GENERAL PUBLIC LICENSE FOR MORE DETAILS.                              
C                                                                       
C YOU SHOULD HAVE RECEIVED A COPY OF THE GNU GENERAL PUBLIC LICENSE     
C ALONG WITH THIS PROGRAM; IF NOT, WRITE TO EDF R&D CODE_ASTER,         
C   1 AVENUE DU GENERAL DE GAULLE, 92141 CLAMART CEDEX, FRANCE.         
C ======================================================================
C RESPONSABLE GENIAUT S.GENIAUT

      IMPLICIT NONE

      INTEGER       NBNOC,NBMAC
      CHARACTER*2   PREFNO(5)
      CHARACTER*8   MO,MALINI,MAXFEM,NOGRFI,RESUCO
      CHARACTER*19  CNS1,CNS2,CES1,CES2,CESVI1,CESVI2
      CHARACTER*24  MAILX,LISTGR,DIRGRM,NIVGRM
C
C      TRAITEMENT DES MAILLES DE MAILX
C       - POUR POST_MAIL_XFEM : CREATION DES MAILLES CORRESPONDANTS
C                               AUX SOUS-ELEMENTS ET CREATION DES NOEUDS
C                               CORRESPONDANTS AUX SOMMETS DES SOUS
C                               ELEMENTS
C       - POUR POST_CHAM_XFEM : CALCUL DES DEPLACEMENTS AUX NOUVEAUX
C                               NOEUDS DE MAXFEM

C
C   IN
C       MO     : MODELE FISSURE
C       MALINI : MAILLAGE SAIN
C       MAILX  : LISTE DES NUMEROS DES MAILLES SOUS-DECOUPEES
C       NBNOC  : NOMBRE DE NOEUDS CLASSIQUES DU MAILLAGE FISSURE
C       NBMAC  : NOMBRE DE MAILLES CLASSIQUES DU MAILLAGE FISSURE
C       PREFNO : PREFERENCES POUR LE NOMAGE DES NOUVELLES ENTITES
C       NOGRFI : NOM DU GROUPE DE NOEUDS SUR LA FISSURE A CREER
C       MAXFEM : MAILLAGE FISSURE (SI POST_CHAMP_XFEM)
C       CNS1   : CHAMP_NO_S DU DEPLACEMENT EN ENTREE
C       CES1   : CHAMP_ELEM_S DE CONTRAINTES EN ENTREE
C       LISTGR : LISTE DES GROUPES CONTENANT CHAQUE MAILLE
C       DIRGRM : VECTEUR D'INDIRECTION ENTRE LES GROUP_MA
C       NIVGRM : VECTEUR DE REMPLISSAGE DES GROUP_MA DE MAXFEM
C       RESUCO : NOM DU CONCEPT RESULTAT DONT ON EXTRAIT LES CHAMPS
C   OUT
C       MAXFEM : MAILLAGE FISSURE (SI POST_MAIL_XFEM)
C       CNS2   : CHAMP_NO_S DU DEPLACEMENT EN SORTIE
C       CES2   : CHAMP_ELEM_S DE CONTRAINTES EN SORTIE
C       NIVGRM : VECTEUR DE REMPLISSAGE DES GROUP_MA DE MAXFEM



C -------------- DEBUT DECLARATIONS NORMALISEES  JEVEUX ----------------
      INTEGER ZI
      COMMON /IVARJE/ZI(1)
      REAL*8 ZR
      COMMON /RVARJE/ZR(1)
      COMPLEX*16 ZC
      COMMON /CVARJE/ZC(1)
      LOGICAL ZL
      COMMON /LVARJE/ZL(1)
      CHARACTER*8 ZK8
      CHARACTER*16 ZK16
      CHARACTER*24 ZK24
      CHARACTER*32 ZK32
      CHARACTER*80 ZK80
      COMMON /KVARJE/ZK8(1),ZK16(1),ZK24(1),ZK32(1),ZK80(1)
      CHARACTER*32 JEXNOM,JEXNUM,JEXATR
C---------------- FIN COMMUNS NORMALISES  JEVEUX  ----------------------


      INTEGER       I,IER,JMAX,NBMAX,ICH,IMA,NIT,IT,CPT,NSE,ISE,IN,NNM
      INTEGER       JCESD(5),JCESV(5),JCESL(5),IAD,JCONX1,JCONX2,NBNOMA
      INTEGER       J,INO,N,NPI,JDIRNO,IBID,JLSN,INOTOT,INN,NNN
      INTEGER       IACOO1,IACOO2,NDIM,IERD,IAD2,INNTOT,NDIME,JTMDIM,INM
      INTEGER       JTYPM1,JTYPM2,IM,INMTOT,ITYPSE(3),IAD1,IADC,IADV
      INTEGER       JCNSE,IAD4,HE,NSEMAX(3),IAD3,JMAIL,ITYPEL,NBELR,JLST
      INTEGER       IGEOM,DDLH,NFE,DDLC,CMP(50),JCNSD1
      INTEGER       NBCMP,JCNSV1,JCNSV2,IAD5,NBNOFI,INOFI
      INTEGER       JCNSL2,JCESV1,JCESD1,JCESL1,JCESV2,JCESD2,JCESL2
      INTEGER       JCVIV1,JCVID1,JCVIL1,JCVIV2,JCVID2,JCVIL2
      INTEGER       NBGMA2,JNIVGR,IAGMA,NGRM,JDIRGR,IAGNO
      CHARACTER*8   K8B,ENTITE,TYPESE(3),ELREFP,LIREFE(10),NOGNO
      CHARACTER*8   TYPMA
      CHARACTER*16  TYSD,K16B,NOMCMD,NOTYPE
      CHARACTER*19  CHS(5),CNSLN,CNSLT
      CHARACTER*24  DIRNO,GEOM,LINOFI,GRPNOE
      LOGICAL       OPMAIL
      INTEGER       IVIEX,IRET,JTYPMA,JCONQ1,JCONQ2,JCNSK1,JVG,JGG,NBNO
      DATA          TYPESE /'SEG2','TRIA3','TETRA4'/
      DATA          NSEMAX /2,3,6/
     
C variable specifique a l ajout d un groupe mail
      CHARACTER*8   NOMA,NOGMAP,NOGMAM,NOMG
      CHARACTER*24  GRPMAE,GRPMAV
      INTEGER       NBGRMA, NBGMIN, NBGMA, NBGRMN,NBMA
      INTEGER       NBMAHEP,NBMAHEM,IAGMAHP,IAGMAHM,JP,JM
      
      CALL JEMARQ()

      CALL JEEXIN(MAILX,IER)
      IF (IER.EQ.0) GO TO 999

C     ------------------------------------------------------------------
C                   RECUPERATION DES OBJETS JEVEUX
C     ------------------------------------------------------------------

      CALL DISMOI('F','DIM_GEOM',MALINI,'MAILLAGE',NDIM,K8B,IER)

C     NOM DE LA COMMANDE (POST_MAIL_XFEM OU POST_CHAM_XFEM)
      CALL GETRES(K8B,K16B,NOMCMD)
      IF (NOMCMD.EQ.'POST_MAIL_XFEM') THEN
        OPMAIL = .TRUE.
      ELSEIF (NOMCMD.EQ.'POST_CHAM_XFEM') THEN 
        OPMAIL = .FALSE.
      ENDIF

      CALL JEVEUO(MAILX,'L',JMAX)
      CALL JELIRA(MAILX,'LONMAX',NBMAX,K8B)

      CHS(1)  = '&&XPOMAX.PINTTO'
      CHS(2)  = '&&XPOMAX.CNSETO'
      CHS(3)  = '&&XPOMAX.LONCHA'
      CHS(4)  = '&&XPOMAX.HEAV'
      CHS(5)  = '&&XPOMAX.AIN'

      CALL CELCES(MO//'.TOPOSE.PIN','V', CHS(1))
      CALL CELCES(MO//'.TOPOSE.CNS','V', CHS(2))
      CALL CELCES(MO//'.TOPOSE.LON','V', CHS(3))
      CALL CELCES(MO//'.TOPOSE.HEA','V', CHS(4))
      CALL CELCES(MO//'.TOPOSE.AIN','V', CHS(5))

      DO 10 ICH=1,5
        CALL JEVEUO(CHS(ICH)//'.CESD','L',JCESD(ICH))
        CALL JEVEUO(CHS(ICH)//'.CESV','E',JCESV(ICH))
        CALL JEVEUO(CHS(ICH)//'.CESL','L',JCESL(ICH))
 10   CONTINUE

      CNSLN='&&XPOMAX.CNSLN'
      CNSLT='&&XPOMAX.CNSLT'
      CALL CNOCNS(MO//'.LNNO','V',CNSLN)
      CALL CNOCNS(MO//'.LTNO','V',CNSLT)
      CALL JEVEUO(CNSLN//'.CNSV','L',JLSN)
      CALL JEVEUO(CNSLT//'.CNSV','L',JLST)

      CALL JEVEUO(MALINI//'.CONNEX','L',JCONX1)
      CALL JEVEUO(JEXATR(MALINI//'.CONNEX','LONCUM'),'L',JCONX2)

      CALL JEVEUO(MALINI//'.COORDO    .VALE','L',IACOO1)
      CALL JEVEUO(MAXFEM//'.COORDO    .VALE','E',IACOO2)

      CALL JEVEUO('&CATA.TM.TMDIM','L',JTMDIM)
      CALL JEVEUO(MALINI//'.TYPMAIL','L',JTYPM1)
      CALL JEVEUO(MAXFEM//'.TYPMAIL','E',JTYPM2)
      CALL JEVEUO(MO//'.MAILLE','L',JMAIL)

      IF (.NOT.OPMAIL) THEN
        CALL JEVEUO(CNS1//'.CNSK','L',JCNSK1)
        CALL JEVEUO(CNS1//'.CNSD','L',JCNSD1)
        CALL JEVEUO(CNS1//'.CNSV','L',JCNSV1)
        CALL JEVEUO(CNS2//'.CNSV','E',JCNSV2)
        CALL JEVEUO(CNS2//'.CNSL','E',JCNSL2)

C  -----SI ON N'A PAS UNE MODE_MECA

        CALL GETTCO(RESUCO,TYSD)
        IF (TYSD(1:9).NE.'MODE_MECA') THEN
          CALL JEVEUO(CES1//'.CESV','L',JCESV1)
          CALL JEVEUO(CES1//'.CESD','L',JCESD1)
          CALL JEVEUO(CES1//'.CESL','L',JCESL1)
          CALL JEVEUO(CES2//'.CESV','E',JCESV2)
          CALL JEVEUO(CES2//'.CESD','L',JCESD2)
          CALL JEVEUO(CES2//'.CESL','E',JCESL2)
        
          CALL JEEXIN(CESVI1//'.CESV',IRET)
          IF(IRET .NE. 0) THEN      
            CALL JEVEUO(CESVI1//'.CESV','L',JCVIV1)
            CALL JEVEUO(CESVI1//'.CESD','L',JCVID1)
            CALL JEVEUO(CESVI1//'.CESL','L',JCVIL1)
          ELSE
            JCVIV1 = 0  
            JCVID1 = 0  
            JCVIL1 = 0  
          ENDIF
          IVIEX = IRET

          CALL JEEXIN(CESVI2//'.CESV',IRET)
          IF(IRET .NE. 0) THEN      
            CALL JEVEUO(CESVI2//'.CESV','E',JCVIV2)
            CALL JEVEUO(CESVI2//'.CESD','L',JCVID2)
            CALL JEVEUO(CESVI2//'.CESL','E',JCVIL2)
          ELSE
            JCVIV2 = 0  
            JCVID2 = 0  
            JCVIL2 = 0  
          ENDIF
          IVIEX = IVIEX*IRET

        ENDIF
      ENDIF

C     RECUP DES NUMEROS DES TYPE DE MAILLES DES SOUS-ELEMENTS
      CALL JENONU(JEXNOM('&CATA.TM.NOMTM',TYPESE(1)),ITYPSE(1))
      CALL JENONU(JEXNOM('&CATA.TM.NOMTM',TYPESE(2)),ITYPSE(2))
      CALL JENONU(JEXNOM('&CATA.TM.NOMTM',TYPESE(3)),ITYPSE(3))

C     COMPTEURS DU NOMBRE DE NOUVEAUX NOEUDS ET MAILLES TOTAL
      INNTOT = 0
      INMTOT = 0
      NBMAHEP = 0
      NBMAHEM = 0

C     COMPTEUR ET LISTE DE NOEUDS PORTANT DES DDLS DE CONTACT
      LINOFI='&&XPOMAX.LINOFI'
      INOFI=-1
      IF (OPMAIL) THEN
        CALL DISMOI('F','NB_NO_MAILLA',MAXFEM,'MAILLAGE',
     &           NBNOFI,K8B,IRET)
        CALL WKVECT(LINOFI,'V V I',NBNOFI,INOFI)
      ENDIF
      NBNOFI=0

C     COMPTEUR DE NUM�ROTATION DES NOMS DES NOUVEAUX NOEUDS
C     ATTENTION, N'EST PAS EGAL AU NOMBRE DE NOUVEAUX NOEUDS
C     CAR LES NOUVEAUX NOUEDS PEUVENT S'APPELER NXP55, NXM55...
C     (POUR LES MAILLES, PAS BESOIN, LES NOMS SONT TOUS MX....)
      INOTOT = 0

C     RECUPERATION DU VECTEUR DE REMPLISSAGE DES GROUP_MA
      IF (OPMAIL) THEN
        CALL JEEXIN(NIVGRM,IRET)
        IF (IRET.NE.0) CALL JEVEUO(NIVGRM,'E',JNIVGR)
      ENDIF

C     RECUPERATION DU VECTEUR D'INDIRECTION ENTRE LES GROUP_MA
      IF (OPMAIL) CALL JEVEUO(DIRGRM,'L',JDIRGR)

C     RECUPERATION DES INFOS DU MAILLAGE SAIN
      IF (.NOT.OPMAIL) THEN
        NOMA=ZK8(JCNSK1-1+1)
        CALL JEVEUO(NOMA//'.TYPMAIL        ','L',JTYPMA)
      ENDIF

C     ------------------------------------------------------------------
C                   BOUCLE SUR LES MAILLES DE MAILX
C     ------------------------------------------------------------------

      DO 100 I = 1,NBMAX

        IMA = ZI(JMAX-1+I)

C       COMPTEUR DES NOUVEAUX NOEUDS ET MAILLES AJOUTES (LOCAL)
        INN = 0
        INM = 0

C       RECUPERATION DU NOMBRE DE NOEUDS (2 METHODES)
        CALL JELIRA(JEXNUM(MALINI//'.CONNEX',IMA),'LONMAX',N,K8B)
        NBNOMA=ZI(JCONX2+IMA) - ZI(JCONX2+IMA-1)
        CALL ASSERT(N.EQ.NBNOMA)

C       RECUPERATION DU NOMBRE DE NIT
        CALL CESEXI('C',JCESD(3),JCESL(3),IMA,1,1,1,IAD3)
        CALL ASSERT(IAD3.GT.0)
        NIT=ZI(JCESV(3)-1+IAD3)

C       RECUPERATION DU NOMBRE DE POINTS D'INTERSECTION
        NPI=ZI(JCESV(3)-1+IAD3+NIT+1)

C       RECUPERATION DU NOMBRE DE NOUVEAUX NOEUDS A CREER 
        NNN=ZI(JCESV(3)-1+IAD3+NIT+2)
        CALL ASSERT(NNN.NE.0)

C       RECUPERATION DES INFOS D'ARETE
        CALL CESEXI('C',JCESD(5),JCESL(5),IMA,1,1,1,IAD5)

C       NOMBRE DE NOUVELLES MAILLES A CREER 
        NNM = 0
        DO 101 IT=1,NIT
          NNM = NNM + ZI(JCESV(3)-1+IAD3+IT)
 101    CONTINUE

C       CREATION DU VECTEUR D'INDIRECTION DES NOEUDS (LOCAL A IMA)
        DIRNO='&&XPOMAX.DIRNO'
        CALL WKVECT(DIRNO,'V V I',(N+NPI)*3,JDIRNO)

C       DIMENSION TOPOLOGIQUE DE LA MAILLE
        NDIME= ZI(JTMDIM-1+ZI(JTYPM1-1+IMA))

C       1ER ELEMENT DE REFERENCE ASSOCIE A LA MAILLE
        ITYPEL = ZI(JMAIL-1+IMA)
        CALL JENUNO(JEXNUM('&CATA.TE.NOMTE',ITYPEL),NOTYPE)
        CALL ELREF2(NOTYPE,10,LIREFE,NBELR)
        ELREFP= LIREFE(1)

C       CREATION DE VECTEUR DES COORDONN�ES DE LA MAILLE IMA
C       AVEC DES VALEURS CONTIGUES
        GEOM = '&&XPOAJD.GEOM'
        CALL WKVECT(GEOM,'V V R',NDIM*N,IGEOM)
        DO 20 IN=1,N
          INO=ZI(JCONX1-1+ZI(JCONX2+IMA-1)+IN-1)
          DO 21 J=1,NDIM
            ZR(IGEOM-1+NDIM*(IN-1)+J)=ZR(IACOO1-1+3*(INO-1)+J)
 21       CONTINUE
 20     CONTINUE

        IF (.NOT.OPMAIL) THEN
C         TYPE DE LA MAILLE PARENT
          CALL JENUNO(JEXNUM('&CATA.TM.NOMTM',ZI(JTYPMA-1+IMA)),TYPMA)
C         CONNECTIVITES DU MAILLAGE QUADRATIQUE
C         POUR RECUPERER LES LAGRANGES
          CALL JEVEUO(NOMA//'.CONNEX','L',JCONQ1)
          CALL JEVEUO(JEXATR(NOMA//'.CONNEX','LONCUM'),'L',JCONQ2)
        ENDIF

C       COMPOSANTES DU CHAMP DE DEPLACEMENT 1 POUR LA MAILLE IMA
C       ET RECUPERATION DES CONTRAINTES 1
        IF (.NOT.OPMAIL) THEN 
          NBCMP = ZI(JCNSD1-1+2)
          CALL XPOCMP(CNS1,IMA,N,JCONX1,JCONX2,NDIM,DDLH,NFE,
     &             DDLC,NBCMP,CMP)
          IF (TYSD(1:9).NE.'MODE_MECA') THEN
            CALL CESEXI('C',JCESD1,JCESL1,IMA,1,1,1,IADC)
            IF(IVIEX .NE. 0) CALL CESEXI('C',JCVID1,JCVIL1,IMA,
     &                                   1,1,1,IADV)
          ENDIF
        ENDIF

C       RECUPERATION DES COORDONNEES DES POINTS D'INTERSECTION
        CALL CESEXI('C',JCESD(1),JCESL(1),IMA,1,1,1,IAD1)
        CALL ASSERT(IAD1.GT.0)

C       RECUPERATION DE LA CONNECTIVITE DES SOUS-ELEMENTS
        CALL CESEXI('C',JCESD(2),JCESL(2),IMA,1,1,1,IAD2)
        CALL ASSERT(IAD2.GT.0)

C       RECUPERATION DE LA FONCTION HEAVISIDE
        CALL CESEXI('C',JCESD(4),JCESL(4),IMA,1,1,1,IAD4)
        CALL ASSERT(IAD4.GT.0)

C       RECUPERATION DES INFOS CONCERNANT LES GROUP_MA CONTENANT IMA
        IF (OPMAIL) THEN
          CALL JEVEUO(JEXNUM(LISTGR,IMA),'L',IAGMA)
          CALL JELIRA(JEXNUM(LISTGR,IMA),'LONMAX',NGRM,K8B)
        ENDIF

C       A) ON AJOUTE LES NOUVEAUX NOEUDS 
C       ---------------------------------

        IN = 0

C       ON AJOUTE LES NOEUDS
        DO 110 J=1,N
          IN = IN + 1
C         INO : NUM�RO DU NOEUD DANS MALINI
C         IL FAUT IMPERATIVEMENT QUE CE SOIT LE MEME NUMERO DANS LE
C         MAILLAGE QUADRATIQUE DU MODELE (VERIFIER QUE LE QUAD-LINE 
C         CONSERVE LA NUMEROTATION DES NOEUDS
          INO=ZI(JCONX1-1+ZI(JCONX2+IMA-1)+J-1)
          ENTITE = 'NOEUD'
          IF (OPMAIL) THEN
            CALL XPOAJN(IN,MAXFEM,ENTITE,INO,JLSN,JDIRNO,IBID,PREFNO,
     &                  NNN,INN,INNTOT,INOTOT,NBNOC,NBNOFI,INOFI,
     &                  IACOO1,IACOO2)
          ELSE
            CALL XPOAJD(ELREFP,ENTITE,N,JLSN,JLST,JCESV(5),IAD5,NPI,
     &                  TYPMA,J,IACOO1,IGEOM,
     &                  NDIME,NDIM,CMP,NBCMP,DDLH,NFE,DDLC,IMA,JCONQ1,
     &                  JCONQ2,JCNSV1,JCNSV2,JCNSL2,NBNOC,INNTOT)
          ENDIF
 110    CONTINUE

C       ON AJOUTE LES POINTS D'INTERSECTION
        DO 120 J=1,NPI
          IN = IN + 1
          IAD = JCESV(1)-1+IAD1+NDIM*(J-1)
          ENTITE = 'POINT'
          IF (OPMAIL) THEN
            CALL XPOAJN(IN,MAXFEM,ENTITE,IBID,JLSN,JDIRNO,NDIM,PREFNO,
     &                  NNN,INN,INNTOT,INOTOT,NBNOC,NBNOFI,INOFI,
     &                  IAD,IACOO2)
          ELSE
            CALL XPOAJD(ELREFP,ENTITE,N,JLSN,JLST,JCESV(5),IAD5,NPI,
     &                  TYPMA,J,IAD,IGEOM,
     &                  NDIME,NDIM,CMP,NBCMP,DDLH,NFE,DDLC,IMA,JCONQ1,
     &                  JCONQ2,JCNSV1,JCNSV2,JCNSL2,NBNOC,INNTOT)
          ENDIF
 120    CONTINUE

        IF (OPMAIL) CALL ASSERT(INN.EQ.NNN) 

C       B) ON AJOUTE LES NOUVELLES MAILLES
C       ---------------------------------

        IM=0
C       BOUCLE SUR LES NIT TETRAS
        DO 130 IT=1,NIT
C         RECUPERATION DU DECOUPAGE EN NSE SOUS-ELEMENTS 
          NSE=ZI(JCESV(3)-1+IAD3+IT)
C         BOUCLE D'INTEGRATION SUR LES NSE SOUS-ELEMENTS
          DO 140 ISE=1,NSE
            IM=IM+1
            HE = ZI(JCESV(4)-1+IAD4-1+NSEMAX(NDIME)*(IT-1)+ISE)
            JCNSE = JCESV(2)-1+IAD2 
            IF (OPMAIL) THEN
              CALL XPOAJM(MAXFEM,JTYPM2,ITYPSE(NDIME),JCNSE,IM,N,
     &                    NDIME,PREFNO,JDIRNO,NNM,INM,INMTOT,NBMAC,HE,
     &                    JNIVGR,IAGMA,NGRM,JDIRGR)
              IF (HE.EQ.1) THEN
	        NBMAHEP=NBMAHEP+1
	      ELSEIF (HE.EQ.-1) THEN
	        NBMAHEM=NBMAHEM+1
              ENDIF
            ELSEIF(.NOT.OPMAIL .AND.(TYSD(1:9).NE.'MODE_MECA')) THEN
C             ON AJOUTE DES CONTRAINTES
              CALL XPOAJC(NNM,INM,INMTOT,NBMAC,NSEMAX(NDIME),IT,ISE,
     &                    JCESD1,JCESD2,JCVID1,JCVID2,IMA,NDIM,NDIME,
     &                    IADC,IADV,JCESV1,JCESL2,JCESV2,JCVIV1,
     &                    JCVIL2,JCVIV2)
            ENDIF
 140      CONTINUE        
 130    CONTINUE

        IF (OPMAIL) CALL ASSERT(IM.EQ.NNM)        
        
        CALL JEDETR(GEOM)
        CALL JEDETR(DIRNO)

 100  CONTINUE

C     CREATION DU GROUPE DES NOEUDS SITUES SUR LA FISSURE 
C     PORTANT DES DDLS DE CONTACT
      GRPNOE=MAXFEM//'.GROUPENO'
      IF (OPMAIL.AND.NBNOFI.GT.0) THEN
        NOGNO=NOGRFI
C       ON SAIT QUE LE .GROUPENO N'EXISTE PAS
        CALL JECREC(GRPNOE,'G V I','NO','DISPERSE','VARIABLE',1)
        CALL JECROC(JEXNOM(GRPNOE,NOGNO))
        CALL JEECRA(JEXNOM(GRPNOE,NOGNO),'LONMAX',NBNOFI,K8B)
        CALL JEVEUO(JEXNOM(GRPNOE,NOGNO),'E',IAGNO)
        DO 210 J = 1,NBNOFI
          ZI(IAGNO-1+J) = ZI(INOFI-1+J)
 210    CONTINUE
      ENDIF
      
C     CREATION DU GROUPE DES mails positive 
      GRPMAE=MAXFEM//'.GROUPEMA'
      IF (OPMAIL.AND.NBMAHEP.GT.0) THEN
        NOGMAP='HEP'
        NOGMAM='HEM'
C       ON detruit les groupes existants

C        CALL JEDETR(GRPMAE)
C        CALL JECREC(GRPMAE,'G V I','NOM','DISPERSE','VARIABLE',1)
	
C     --- ON AGRANDIT LA COLLECTION ---
C
       GRPMAV  = '&&OP0104'//'.GROUPEMA       '
       NBGMIN = 0
       NBGRMA = 2
       CALL JEEXIN(GRPMAE,IRET)
       IF ( IRET .EQ. 0  .AND.  NBGRMA .NE. 0 ) THEN
          CALL JECREC(GRPMAE,'G V I','NOM','DISPERSE','VARIABLE',NBGRMA)
       ELSEIF ( IRET .EQ. 0  .AND.  NBGRMA .EQ. 0 ) THEN
       ELSE
         CALL JELIRA(GRPMAE,'NOMUTI',NBGMA,K8B)
         NBGMIN = NBGMA
         NBGRMN = NBGMA + NBGRMA
         CALL JEDUPO( GRPMAE, 'V', GRPMAV, .FALSE. )
         CALL JEDETR ( GRPMAE )
         CALL JECREC(GRPMAE,'G V I','NOM','DISPERSE','VARIABLE',NBGRMN)
         DO 290 I = 1 , NBGMA
            CALL JENUNO(JEXNUM(GRPMAV,I),NOMG)
            CALL JECROC(JEXNOM(GRPMAE,NOMG))
            CALL JEVEUO(JEXNUM(GRPMAV,I),'L',JVG)
            CALL JELIRA(JEXNUM(GRPMAV,I),'LONMAX',NBMA,K8B)
            CALL JEECRA(JEXNOM(GRPMAE,NOMG),'LONMAX',NBMA,' ')
            CALL JEVEUO(JEXNOM(GRPMAE,NOMG),'E',JGG)
            DO 291 J = 0 , NBMA-1
               ZI(JGG+J) = ZI(JVG+J)
 291        CONTINUE
 290     CONTINUE
        ENDIF
	
        CALL JECROC(JEXNOM(GRPMAE,NOGMAP))
        CALL JEECRA(JEXNOM(GRPMAE,NOGMAP),'LONMAX',NBMAHEP,K8B)
        CALL JEVEUO(JEXNOM(GRPMAE,NOGMAP),'E',IAGMAHP)
	CALL JECROC(JEXNOM(GRPMAE,NOGMAM))
        CALL JEECRA(JEXNOM(GRPMAE,NOGMAM),'LONMAX',NBMAHEM,K8B)
        CALL JEVEUO(JEXNOM(GRPMAE,NOGMAM),'E',IAGMAHM)
	JP=0
	JM=0
	INMTOT = 0
	DO 300 I = 1,NBMAX
          IMA = ZI(JMAX-1+I)
C         COMPTEUR DES NOUVEAUX NOEUDS ET MAILLES AJOUTES (LOCAL)
          INN = 0
          INM = 0


C         RECUPERATION DU NOMBRE DE NIT
          CALL CESEXI('C',JCESD(3),JCESL(3),IMA,1,1,1,IAD3)
          CALL ASSERT(IAD3.GT.0)
          NIT=ZI(JCESV(3)-1+IAD3)
	  
	  CALL CESEXI('C',JCESD(4),JCESL(4),IMA,1,1,1,IAD4)
C         BOUCLE SUR LES NIT TETRAS
          DO 330 IT=1,NIT
C           RECUPERATION DU DECOUPAGE EN NSE SOUS-ELEMENTS 
            NSE=ZI(JCESV(3)-1+IAD3+IT)
C           BOUCLE D'INTEGRATION SUR LES NSE SOUS-ELEMENTS
            DO 340 ISE=1,NSE
              IM=IM+1
              HE = ZI(JCESV(4)-1+IAD4-1+NSEMAX(NDIME)*(IT-1)+ISE)
	      INMTOT=INMTOT+1
              IF (HE.EQ.1) THEN
                JP=JP+1
		ZI(IAGMAHP-1+JP) = NBMAC + INMTOT
	      ELSEIF (HE.EQ.-1) THEN
                JM=JM+1
		ZI(IAGMAHM-1+JM) = NBMAC + INMTOT
	      ENDIF
 340	    CONTINUE
 330	  CONTINUE
 300    CONTINUE
      ENDIF

      CALL DETRSD('CHAM_NO_S',CNSLN)
      CALL DETRSD('CHAM_NO_S',CNSLT)
      CALL DETRSD('CHAM_ELEM_S',CHS(1))
      CALL DETRSD('CHAM_ELEM_S',CHS(2))
      CALL DETRSD('CHAM_ELEM_S',CHS(3))
      CALL DETRSD('CHAM_ELEM_S',CHS(4))
      IF (OPMAIL) CALL JEDETR(MAILX)
      IF (OPMAIL) CALL JEDETR(LINOFI)

 999  CONTINUE

      CALL JEDEMA()
      END