--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll


--------------------------------------------------------------------------------
config :: Configuration
config = defaultConfiguration {
  destinationDirectory = "docs"
                              }

main :: IO ()
main = hakyllWith config $ do
    match "images/*" $ do
        route   idRoute
        compile $ copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["about.md", "contact.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" defaultContext
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls


    match "lecturas/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls

    match "ayudantias/*" $ do
      route idRoute
      compile copyFileCompiler

    match "ayudantias/mat023/*" $ do
      route idRoute
      compile copyFileCompiler

    match "ayudantias/mat021/*" $ do
      route idRoute
      compile copyFileCompiler

    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    constField "title" "Archivo"             `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= relativizeUrls

    create ["lecturas.html"] $ do
      route $ setExtension "html"
      compile $ do
        lecturas <- recentFirst =<< loadAll "lecturas/*"
        let librosCtx =
              listField "lecturas" postCtx (return lecturas) `mappend`
              constField "title" "Lecturas"                  `mappend`
              defaultContext

        makeItem ""
            >>= loadAndApplyTemplate "templates/lecturas.html" librosCtx
            >>= loadAndApplyTemplate "templates/default.html" librosCtx
            >>= relativizeUrls

    create ["ayudantias_al_papel.html"] $ do
      route $ setExtension "html"
      compile $ do
        ayudantias <- getMatches "ayudantias/mat023/*"
        ayuss <- getMatches "ayudantias/mat021/*"
        let ayu = fmap(\ident -> Item ident (toFilePath ident)) ayudantias
        let ayus = fmap(\ident -> Item ident (toFilePath ident)) ayuss
        let librosCtx =
              listField "ayudantias-023"   postCtx (return ayu) `mappend`
              listField "ayudantias-021"   postCtx (return ayus) `mappend`
              constField "title" "Ayudantias"                  `mappend`
              defaultContext

        makeItem ""
            >>= loadAndApplyTemplate "templates/ayudantias.html" librosCtx
            >>= loadAndApplyTemplate "templates/default.html" librosCtx
            >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll "posts/*"
            ayus <- getMatches "ayudantias/mat023/*"
            let lecturas = fmap(\ident -> Item ident (toFilePath ident)) ayus
            let indexCtx =
                    listField "posts" postCtx (return posts)       `mappend`
                    listField "lecturas" postCtx (return lecturas) `mappend`
                    defaultContext

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateBodyCompiler


--------------------------------------------------------------------------------
postCtx :: Context String
postCtx =
    dateField "date" "%e/%m/%Y" `mappend`
    defaultContext
